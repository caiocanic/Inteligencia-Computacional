function [dJdA, dJdB] = calcGrad(X,Yd,A,B,N)
	Zin = X*A';
	Z = tanh(Zin);
	Yin = [Z,ones(N,1)]*B';
	Y = tanh(Yin);
	erro = Y-Yd;
	dJdB = 1/N*(erro.*(1-Y.*Y))'*[Z,ones(N,1)];
	dJdZ = (erro.*(1-Y.*Y))*B;
	dJdZ = dJdZ(:,1:end-1);
	dJdA = 1/N*(dJdZ.*(1-Z.*Z))'*X;
end