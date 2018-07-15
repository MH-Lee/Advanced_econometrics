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
				df = n-k; /*자유도*/
				xpx = x`*x;/*xp = xprime*/
				xpy = x`*y;
				xpxi = INV(xpx);/*역함수*/
				b = xpxi*xpy;
				yhat = x*b;
				e = y-yhat;
				sse = e`*e;
				mse = sse/df;
				covb = mse#xpxi;/*# means 곱하기*/
				stdb = SQRT(VECDIAG(covb));/*분산만 빼서 루트를 취함.*/
				t = b/stdb;
				probt = 1- PROBF(t#t,1,df);/*# 각각 같은열의 원소를 곱해줌  nX1 nX1행렬을  곱하게 해줌, 1,분자와 분모의 자유도*/
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
				df = n-k; /*자유도*/
				xpx = x`*x;/*xp = xprime*/
				xpy = x`*y;
				xpxi = INV(xpx);/*역함수*/
				b = xpxi*xpy;
				yhat = x*b;
				e = y-yhat;
				sse = e`*e;
				mse = sse/df;
				covb = mse#xpxi;  /*# means 곱하기*/
				stdb = SQRT(VECDIAG(covb));/*분산만 빼서 루트를 취함.*/
				t = b/stdb;
				probt = 1- PROBF(t#t,1,df);/*# 각각 같은열의 원소를 곱해줌  nX1 nX1행렬을  곱하게 해줌, 1,분자와 분모의 자유도*/
				PRINT "result of regression are" b stdb t probt;
			FINISH reg;
		RUN reg;

		START rsquare;
				iota = J(n,1,1);/*j 모든 원소가 1로 이루어진 nx1을 만들라는 함수 */
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
