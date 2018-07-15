DATA ip;
          INFILE 'c:\data\ip.prn';
          INPUT mon ip;
		  logip = LOG(ip);
          ipg = DIF(logip)*1200;
		  IF mon < 19590101 THEN DELETE;
RUN;
DATA fyff;
		INFILE 'c:\data\fyff.prn';
        INPUT mon fyff;
		fyff4 = LAG4(fyff);
		IF mon < 19590101 THEN DELETE;
RUN;
DATA ex;
	MERGE ip fyff;
	BY mon;
	int=1;
RUN;
PROC IML;
	RESET NOPRINT;
	START reg;
				n = NROW(x);
				k = NCOL(x);
				dfe = n-k; /*자유도*/
				xpx = x`*x;/*xp = xprime*/
				xpy = x`*y;
				xpxi = INV(xpx);/*역함수*/
				b = xpxi*xpy;
				yhat = x*b;
				e = y-yhat;
				sse = e`*e;
				mse = sse/dfe;
				covb = mse#xpxi;/*# means 곱하기*/
				stdb = SQRT(VECDIAG(covb));/*분산만 빼서 루트를 취함.*/
				t = b/stdb;
				probt = 1- PROBF(t#t,1,dfe);/*# 각각 같은열의 원소를 곱해줌  nX1 nX1행렬을  곱하게 해줌, 1,분자와 분모의 자유도*/
				PRINT name  b stdb t probt;
		FINISH reg;
	USE ex;
	READ ALL VAR{ipg} into y;
	READ ALL VAR{int fyff4} into x;
	 name = {"intercept","fyff4"};
RUN reg; 

START test;
	dfn = nrow(rr);
	rrb = rr*b; /*R = rr = L*/
	rrirri = inv(rr*xpxi*rr`);
	numer = (rrb-r)`*rrirri*(rrb-r)/dfn;
	denom= mse;
	tau = numer/denom;
	prob = 1-PROBF(tau,dfn,dfe);
	PRINT ,tau,dfn,dfe,prob;
FINISH test;
	rr={0 1};
	r = {0};
RUN TEST;
