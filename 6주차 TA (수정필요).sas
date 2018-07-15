DATA ip;
			INFILE 'c:\data\ip.prn';
			INPUT mon ip;
			ipg = DIF(LOG(ip))*100;
RUN;
DATA sp;
			INFILE 'c:\data\sp500.prn';
			INPUT mon sp;
			spg = DIF(LOG(sp))*100;
RUN;
DATA ex01;
	MERGE ip sp;
	BY mon;
	int = 1;
	WHERE 19570101 < mon < 20120801;
RUN;
DATA st;
	SET ex01;
	IF mon<20070101 THEN DO; /*2007년 01월 01일을 기준으로 structural change가 존재하는지 확인하기*/
		int1=1;
		int2=0;
		spg1=spg;
		spg2=0;
	END;
	ELSE DO;
		int1=0;
		int2=1;
		spg1=0;
		spg2=spg;
	END;
RUN;
PROC REG DATA=ex01;
	MODEL ipg = spg/DW DWPROB;
RUN;
PROC IML;
	START reg;
				n = NROW(x);
				k = NCOL(x);
				df = n-k;
				xpx = x`*x;
				xpy = x`*y;
				xpxi = INV(xpx);
				b = xpxi*xpy;
				yhat = x*b;
				e = y-yhat;
				sse = e`*e;
				mse = sse/df;
				covb = mse#xpxi;
				stdb = SQRT(VECDIAG(covb));
				t = b/stdb;
				probt = 1- PROBF(t#t,1,df);
				PRINT "result of regression are" b stdb t probt;
				e1 = LAG(e,1);
				em = e-e1;
				em[1,1] = 0;
				emsq = em`*em;
				dw=emsq/sse;
				PRINT "durbin watson-d is" dw;
	FINISH reg;
	USE ex01;
		READ all VAR{ipg} into y;
		READ all VAR{int spg} into x;
	RUN reg;
PROC IML;
	START joint;
				n = NROW(x);
				k = NCOL(x);
				df = n-k;
				xpx = x`*x;
				xpy = x`*y;
				xpxi = INV(xpx);
				b = xpxi*xpy;
				yhat = x*b;
				e = y-yhat;
				sse = e`*e;
				mse = sse/df;
				br=rr*b;
				q=nrow(rr);
				brr=br-r;
				tr=rr*xpxi*rr`;
				tri=inv(tr);
				ta=brr`*tri*brr/q;
				tau=ta/mse;
				probtau=1-probf(tau,q,df);
		print tau q df probtau;
	FINISH joint;
	do;
		rr={1 -1 0 0 ,
			0 0 1 -1};
		r={0, 0};
	END;
USE st;
		READ all VAR {ipg} into y;
		READ all VAR {int1 int2 spg1 spg2} into x;
QUIT;
PROC IML;
	START chow;
		n = NROW(x);
		k = NCOL(x);
		df = n-k;
		xpx = x`*x;
		xpy = x`*y;
		xpxi = INV(xpx);
		b = xpxi*xpy;
		yhat = x*b;
		e = y-yhat;
		sse = e`*e;
		mse = sse/df;
	FINISH chow;
	USE ex01;
		READ all VAR{ipg} into y;
		READ all VAR{int spg} into x;
	RUN chow;
	n0 = n;

	USE ex;
		READ all VAR{ipg} into y;
		READ all VAR{int spg} into x;
	RUN chow;
	sse1 = sse;
	mse1 = mse;
	n1=n;
	df1 = df;

	USE ex;
		READ all VAR{ipg} into y;
		READ all VAR{int spg} into x;
	RUN chow;
	sse2=sse;
	mse2=mse;
	n2=n;
	df2=df;
	/*chow testsms homoscedasticity를 전제로 하기 때문에 f-test를 선행으로 해주어야함. 그 결과가 probvf가 0.05보다 작으면
	chow test를 사용할 수 없다.*/
	vf =mse1/mse2;
	vfinv=1/vf;
	provvf=1-probf(vf, df1, df2);
	provfinv = 1-probf(vfinv, df2,df1);
	PRINT "comparemse" mse1 mse2, "f-values are" vf vfinv, "probs are" probvf probvfinv;
/*pchow predictive chow*/
	dfn=n2;
	dfe=n1-k;
	numer=(sse0-sse1)/dfn;
	denom=(sse1+sse2)/dfe;
	pchow=numer/denom;
	probpchow = 1-probf(pchow, dfn, dfe);
	PRINT "chow" pchow probpchow;
/*CHOW*/
	dfn=k;
	dfe=n0-2*k;
	numer=(sse0-sse1)/dfn;
	denom=(sse1+sse2)/dfe;
	pchow=numer/denom;
	probpchow = 1-probf(pchow, dfn, dfe);
	PRINT "chow" pchow probpchow;
QUIT;
/*6.03*/
DATA ip;
			INFILE 'c:\data\ip.prn';
			INPUT mon ip;
			ipg = DIF(LOG(ip))*100;
RUN;
DATA sp;
			INFILE 'c:\data\sp500.prn';
			INPUT mon sp;
			spg = DIF(LOG(sp))*100;
RUN;
DATA m1;
			INFILE 'c:\data\m1_usa.prn';
			INPUT mon m1;
RUN;
DATA fyff;
			INFILE 'c:\data\fyff.prn';
			INPUT mon fy;
			fy4= LAG4(fy);
RUN;
DATA ex03;
	MERGE ip sp fyff;
	BY mon;
	IF mon < 19940901 THEN DELETE;
RUN;
DATA ex03;
	MERGE m1 ex03;
	BY mon;
	IF mon > 20120701 THEN DELETE;
RUN;
PROC REG DATA = ex03;
		MODEL ip = m1 spg fy4;
		MODEL ip = fy4;
RUN;
PROC IML;
		USE ex03;
		READ all VAR{m1 spg fy4} to x;
		START fng;
			n = NROW(x);
			k = NCOL(x)+1;
			iota = J(n,1,1);
			a=I(n) - (1/n)*iota*iota`;
			ax = a*x
			ax2 = ax#ax;
			sum = ax2[+,];
			rootsum = sum##(1/2);
			rooti = 1/rootsum;
			r = ax#rooti;
			rx = r`*r;
			drx = det(rx);
			if drx>0 THEN dr = drx;
			else dr = 1/10000;
			lnrx = log(dr);
			pow = (-1)*((n-1)-(1/6)*(2*(k-1)+5));
			chi = pow*inrx;
			df = (1/2)*(k-1)*(k-2);
			probfng =1-probchi(chi, df);
			PRINT "Farrar & Gluber test" dr lnrx chi probfng;
		FINISH fng;
	RUN fng;
QUIT
