function [A,B,Y] = mlp(X,d,h)
	[N,ne] = size(X);
	ns = size(d,2);

	%Adiciona o bias
	X = [X, ones(N,1)];

	%Inicializa as matrizes de pesos A e B
	A = rands(h,ne+1)/5;
	B = rands(ns,h+1)/5;
	
	Y = calc_saida(A,B,X,N);
	erro = Y-d;
	EQM = 1/N*sum(sum(erro.*erro));
	nepMax = 30000;
	nep = 0;
	alfa = 0.3;

	while EQM > 1.0e-5 && nep < nepMax
		nep = nep+1;
		[dJdA, dJdB] = calc_grad(X,d,A,B,N);
		A = A - alfa*dJdA;
		B = B - alfa*dJdB;
		Y = calc_saida(A,B,X,N);
		erro = Y-d;
		EQM = 1/N*sum(sum(erro.*erro));
		fprintf("EQM: %f\n",EQM);
	end
end

function Y = calc_saida(A,B,X,N)
	Zin = X*A';
	Z = tanh(Zin);

	%Checar o bias do Z
	Yin = [Z,ones(N,1)]*B';
	Y = tanh(Yin);
end

function [dJdA, dJdB] = calc_grad(X,d,A,B,N)
	Zin = X*A';
	Z = tanh(Zin);
	Yin = [Z,ones(N,1)]*B';
	Y = tanh(Yin);
	erro = Y-d;
	
	dJdB = 1/N*(erro.*(1-Y.*Y))'*[Z,ones(N,1)];
	dJdZ = (erro.*(1-Y.*Y))*B;
	dJdZ = dJdZ(:,1:end-1);
	dJdA = 1/N*(dJdZ.*(1-Z.*Z))'*X;
end