%Retorna o grádiente
function dJdA = grad(X,Yd,A,N)
	[Y,erro] = calcSaida(X,Yd,A);
	dJdA = 1/N*(erro.*((1-Y).*Y))'*X;
end