/*9.01 (1)&(2)*/
DATA ip;
	INFILE "C:\data\ip.prn";
	INPUT mon ip;
	ipg = DIF(log(ip))*100;
RUN;
DATA fy;
	INFILE "C:\data\fyff.prn";
	INPUT mon fy;
	fy4 = lag4(fy);
RUN;
DATA sp;
	INFILE "C:\data\sp500.prn";
	INPUT mon sp;
	spg = DIF(log(sp))*100;
RUN;
DATA ex03;
	MERGE ip fy sp; 
	BY mon;
	IF mon <19570101 THEN DELETE;	 
RUN;
PROC AUTOREG DATA = ex03;
	MODEL spg = fy4/NLAG = 1 GARCH=(q=1, p=1) METHOD = ml;
	OUTPUT OUT = out1 CEV = ht;
RUN;
DATA ex03;
	SET out1;
	sht = sqrt(ht);
RUN;
PROC AUTOREG DATA = ex03;
	MODEL ipg = fy4 sht/NLAG = 1 METHOD = ml;
Run;

/*9.03 (3)*/ 
DATA all;
	MERGE ip fy;
 	BY mon;
	WHERE 19590101<=mon<=20120701;
RUN;
/* Capturing ODS tables into SAS data sets */
ODS OUTPUT Autoreg.egarch_1_1.FinalModel.Results.FitSummary
=e1;
ODS OUTPUT Autoreg.egarch_1_2.FinalModel.Results.FitSummary
=e2;
ODS OUTPUT Autoreg.egarch_2_1.FinalModel.Results.FitSummary
=e3;
ODS OUTPUT Autoreg.egarch_2_2.FinalModel.Results.FitSummary
=e4;
PROC AUTOREG DATA = all OUTEST =test(rename=(_MODEL_=MODEL _A_1=A1 _AH_0=AH0 _AH_1=AH1 _AH_2=AH2
_GH_1=GH1 _GH_2=GH2 _THETA_=THETA));
	egarch_1_1: MODEL ipg=fy4/NOINT NLAG=1 METHOD=ml maxit=200 GARCH=(p=1,q=1, type=exp);
	egarch_1_2: MODEL ipg=fy4/NOINT NLAG=1 METHOD=ml maxit=200 GARCH=(p=1,q=2, type=exp); 
	egarch_2_1: MODEL ipg=fy4/NOINT NLAG=1 METHOD=ml maxit=200 GARCH=(p=2,q=1, type=exp); 
	egarch_2_2: MODEL ipg=fy4/NOINT NLAG=1 METHOD=ml maxit=200 GARCH=(p=2,q=2, type=exp);
RUN;
/* Printing summary table of parameter estimates */
TITLE "Parameter Estimates for Different Models"; 
PROC PRINT DATA=test;
	VAR MODEL A1 AH0 AH1 AH2 GH1 GH2 THETA;
RUN;
/* Merging ODS output tables and extracting AIC and SBC measures */
DATA sbc_aic;
	SET e1 e2 e3 e4; 
	KEEP Model SBC AIC;
	IF Label1="SBC" THEN DO; SBC=input(cValue1,BEST12.4); END;
	IF Label2="SBC" THEN DO; SBC=input(cValue2,BEST12.4); END;
	IF Label1="AIC" THEN DO; AIC=input(cValue1,BEST12.4); END;
	IF Label2="AIC" THEN DO; AIC=input(cValue2,BEST12.4); END; 
	IF not (SBC=.) then output;
RUN;
/* Sorting data by AIC criterion */
PROC SORT DATA=sbc_aic;
	BY AIC;
RUN;
TITLE "Selection Criteria for Different Models"; 
PROC PRINT DATA=sbc_aic;
FORMAT _NUMERIC_;
RUN;
