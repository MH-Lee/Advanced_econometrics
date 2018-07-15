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
	MODEL ipg = fyff4/chow = (100 200) pchow = (100 200);
	OUTPUT OUT = out1 cusum = cu cusumsq = cusq	cusumub = cuub cusumlb = culb cusumsqub = cusqub cusumsqlb = cusqlb;
RUN;
DATA ex01;
	SET out1;
	time = _N_;
RUN;
PROC GPLOT DATA = ex01;
	SYMBOL1 v =none  i=join;
	SYMBOL2 v =none i=join;
	SYMBOL3 v =none i=join;
	PLOT cu*time = 1 
			cuub*time = 2
			culb*time = 3/OVERLAY;
RUN;
PROC GPLOT DATA = ex01;
	SYMBOL1 v =none  i=join;
	SYMBOL2 v =none i=join;
	SYMBOL3 v =none i=join;
	PLOT cusq*time = 1 
			cusqub*time = 2
			cusqlb*time = 3/OVERLAY;
RUN;
