PROC IML;
	PRINT "Result of 3.01";
	a = {1 -1 3 1,
			0 1 7 1,
			-4 4 1 -2,
			2 1 0 1};
	b = {1, 5, 2, 3};
	x1 = solve(a,b);
	inv = inv(a);
	x2 = inv*b;
	PRINT a, b;
	PRINT x1, x2;
QUIT;
PROC IML;
	PRINT "Result of 3.02";
	a1 = {2 1 1,
			0 3 0,
			0 1 4};
	CALL eigen(lamda1, c1, a1);
	PRINT "The eigenvalues of a1 are" lamda1;
	PRINT "The eigenvalues of a1 are" c1;
QUIT;
PROC IML;
	PRINT "Result of 3.022";
	b1 = {1 0 2,
	       1 2 0,
	       0 0 3};
	CALL eigen(lamda1, c1, b1);
	PRINT "The eigenvalues of b1 are" lamda1;
	PRINT "The eigenvalues of b1 are" c1;
QUIT;
PROC IML;
	RESET noprint;
		x = {7 -1 -1,
			10 -2 1,
			6 3 -2};
			detx = det(x);
			invx = inv(x);
			invx1 = -61*jnvx;
			/*jnv에 61를 원래의 근사값이 나오므로 알아보기 쉽게 -61을  곱해준다.*/
			print, "determination of X matrix" detx;
			print, "inverse matrix X" invx;
			print, invx1;
QUIT;	
