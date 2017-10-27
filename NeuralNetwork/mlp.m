function [A,B,Y] = mlp(Xtr,Ydtr,Xvl,Ydvl,Xts,h)
	[A,B] = treinamento(Xtr,Ydtr,Xvl,Ydvl,h);
	Y = teste(A,B,Xts);
end

function [A,B] = treinamento(Xtr,Ydtr,Xvl,Ydvl,h)
	alfa = 0.1;
	nepMax = 20000;
	nep = 1;
	[N,ne] = size(Xtr);
	ns = size(Ydtr,2);
	%Adiciona o bias
	Xtr = [Xtr, ones(N,1)];
	%Inicializa as matrizes de pesos A e B
	A = rands(h,ne+1)/5;
	B = rands(ns,h+1)/5;
	
	Y = calc_saida(A,B,Xtr,N);
	erro = Y-Ydtr;
	EQM(nep) = 1/N*sum(sum(erro.*erro));
	while EQM(nep) > 1.0e-5 && nep < nepMax
		nep = nep+1;
		[dJdA, dJdB] = calc_grad(Xtr,Ydtr,A,B,N);
		%alfa = calc_alfa(A,B,dJdA,dJdB,Xtr,Yd,N);
		A = A - alfa*dJdA;
		B = B - alfa*dJdB;
		Y = calc_saida(A,B,Xtr,N);
		erro = Y-Ydtr;
		EQM(nep) = 1/N*sum(sum(erro.*erro));
		fprintf("EQM: %f\n",EQM(nep));
		
		%Validação
	end
	plot(EQM);
end

function Y = teste(A,B,Xts)
	[N,~] = size(Xts);
	%Adiciona o bias
	Xts = [Xts, ones(N,1)];
	Y = calc_saida(A,B,Xts,N);
end

function Y = calc_saida(A,B,X,N)
	Zin = X*A';
	Z = tanh(Zin);

	%Checar o bias do Z
	Yin = [Z,ones(N,1)]*B';
	Y = tanh(Yin);
end