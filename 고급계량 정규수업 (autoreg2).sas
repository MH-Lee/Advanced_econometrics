DATA ip;
			INFILE 'c:\data\ip.prn';
			INPUT mon ip;
			ipg = DIF(LOG(ip))*1200;
RUN;
DATA fyff;
			INFILE 'c:\data\fyff.prn';
			INPUT mon fyff;
			fyff4=LAG4(fyff);
RUN;
DATA ex01;
			MERGE ip fyff;
			BY mon;
			IF mon < 19570101 THEN DELETE;
RUN;
PROC AUTOREG DATA =ex01;
	MODEL ipg = fyff4/NLAG =1 METHOD= ML MAXIT=200 DWPROB;
RUN;

