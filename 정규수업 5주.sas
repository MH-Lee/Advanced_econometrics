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
				dfe = n-k; /*������*/
				xpx = x`*x;/*xp = xprime*/
				xpy = x`*y;
				xpxi = INV(xpx);/*���Լ�*/
				b = xpxi*xpy;
				yhat = x*b;
				e = y-yhat;
				sse = e`*e;
				mse = sse/dfe;
				covb = mse#xpxi;/*# means ���ϱ�*/
				stdb = SQRT(VECDIAG(covb));/*�л길 ���� ��Ʈ�� ����.*/
				t = b/stdb;
				probt = 1- PROBF(t#t,1,dfe);/*# ���� �������� ���Ҹ� ������  nX1 nX1�����  ���ϰ� ����, 1,���ڿ� �и��� ������*/
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
