DATA ip;
			INFILE 'c:\data\ip.prn';
			INPUT mon ip;
			ipg = DIF(LOG(ip))*1200;
RUN;
DATA sp;
			INFILE 'c:\data\sp500.prn';
			INPUT mon sp;
			spg = DIF(LOG(sp))*1200;
RUN;
DATA all;
			MERGE ip sp;
			BY mon;
			int =1;
			WHERE  19570201<=mon<=20120701;
RUN;
PROC REG DATA = all;
	MODEL ipg =spg/DW DWPROB;
RUN;
PROC IML;
	START reg;
				n = NROW(x);
				k = NCOL(x);
				df = n-k; /*������*/
				xpx = x`*x;/*xp = xprime*/
				xpy = x`*y;
				xpxi = INV(xpx);/*���Լ�*/
				b = xpxi*xpy;
				yhat = x*b;
				e = y-yhat;
				sse = e`*e;
				mse = sse/df;
				covb = mse#xpxi;/*# means ���ϱ�*/
				stdb = SQRT(VECDIAG(covb));/*�л길 ���� ��Ʈ�� ����.*/
				t = b/stdb;
				probt = 1- PROBF(t#t,1,df);/*# ���� �������� ���Ҹ� ������  nX1 nX1�����  ���ϰ� ����, 1,���ڿ� �и��� ������*/
				PRINT "result of regression are" b stdb t probt;
				e1 = LAG(e,1);
				em = e-e1;
				em[1,1] = 0;
				emsq = em`*em;
				dw=emsq/sse;
				PRINT "durbin watson-d" DW;
		FINISH reg;
	USE all;
		READ all VAR {ipg} into y;
		READ all VAR {int spg} into x;
	RUN reg;
QUIT;
PROC IML;
		y={-0.1, 3.6, 2.7, 4, 2.7, 3.8, 4.5, 4.4, 4.7,
		  4.1, 1, 1.8, 2.8, 3.8, 3.3, 2.7, 1.8, -0.3};
		 x={1 8.7 4,
		  1 12 3,
		  1 9.6 3,
		  1 -0.3 5.5,
		  1 -2.3 5.5,
		  1 -0.6 5.25,
		  1 0.5 5.5,
		  1 0.7 4.75,
		  1 7.9 5.5,
		  1 -5.5 6.5,
		  1 -0.6 1.83,
		  1 0.9 1.25,
		  1 7.8 1,
		  1 6.1 2.25,
		  1 0.1 4.25,
		  1 -1.1 5.25,
		  1 0.4 4.25,
		  1 3.8 0.13};
	name = {"intercept", "M1", "interest"};

		START reg;
				n = NROW(x);
				k = NCOL(x);
				df = n-k; /*������*/
				xpx = x`*x;/*xp = xprime*/
				xpy = x`*y;
				xpxi = INV(xpx);/*���Լ�*/
				b = xpxi*xpy;
				yhat = x*b;
				e = y-yhat;
				sse = e`*e;
				mse = sse/df;
				covb = mse#xpxi;  /*# means ���ϱ�*/
				stdb = SQRT(VECDIAG(covb));/*�л길 ���� ��Ʈ�� ����.*/
				t = b/stdb;
				probt = 1- PROBF(t#t,1,df);/*# ���� �������� ���Ҹ� ������  nX1 nX1�����  ���ϰ� ����, 1,���ڿ� �и��� ������*/
				PRINT "result of regression are" b stdb t probt;
			FINISH reg;
		RUN reg;

		START rsquare;
				iota = J(n,1,1);/*j ��� ���Ұ� 1�� �̷���� nx1�� ������ �Լ� */
				a=i(n)-(1/n)*iota*iota`;
				ys=a*y;
				tss = ys`*ys;
				rsquare=1-sse/tss;
				denom=tss/(n-1);
				adjr2=1-mse/denom;
				PRINT "rsquare" rsquare;
				PRINT "adjusted rsquare" adjr2;
			FINISH rsquare;
		RUN rsquare;
	QUIT;
