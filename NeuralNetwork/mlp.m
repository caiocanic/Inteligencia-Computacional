function [A,B,Y] = mlp(Xtr,Ydtr,Xvl,Ydvl,Xts,h)
	[A,B] = treinamento(Xtr,Ydtr,Xvl,Ydvl,h);
	Y = teste(A,B,Xts);
end

function [A,B] = treinamento(Xtr,Ydtr,Xvl,Ydvl,h)
	alfa = 0.1;
	nepMax = 20000;
	nep = 1;
	[Ntr,netr] = size(Xtr);
	[Nvl,~] = size(Xvl);
	ns = size(Ydtr,2);
	%Adiciona o bias
	Xtr = [Xtr, ones(Ntr,1)];
	Xvl = [Xvl, ones(Nvl,1)];
	%Inicializa as matrizes de pesos A e B
	A = rands(h,netr+1)/5;
	B = rands(ns,h+1)/5;
	%Inicia Treinamento
	[dJdA, dJdB] = calcGrad(Xtr,Ydtr,A,B,Ntr);
	Y = calcSaida(A,B,Xtr,Ntr);
	errotr = Y-Ydtr;
	EQMtr(nep) = 1/Ntr*sum(sum(errotr.*errotr));
	%Inicia Validação
	Yvl = calcSaida(A,B,Xvl,Nvl);
	errovl = Yvl-Ydvl;
	EQMvl(nep) = 1/Nvl*sum(sum(errovl.*errovl));
	EQMvlBest = EQMvl(nep);
	while EQMtr(nep) > 1.0e-5 && nep < nepMax
		nep = nep+1;
		%Atualiza os pesos
		Anew = A - alfa*dJdA;
		Bnew = B - alfa*dJdB;
		%Validação
		Yvl = calcSaida(Anew,Bnew,Xvl,Nvl);
		errovl = Yvl-Ydvl;
		EQMvl(nep) = 1/Ntr*sum(sum(errovl.*errovl));
		if EQMvl(nep) < EQMvlBest
			ABest = A;
			BBest = B;
			EQMvlBest = EQMvl(nep-1);
		end
		A = Anew;
		B = Bnew;
		%Recálcula o gradiente
		dJdAOld = dJdA;
		dJdBOld = dJdB;
		[dJdA, dJdB] = calcGrad(Xtr,Ydtr,A,B,Ntr);
		%Cálcula o novo alfa
		alfa = calcAlfa(dJdAOld,dJdBOld,dJdA,dJdB,alfa);
		%Cálcula o erro
		Y = calcSaida(A,B,Xtr,Ntr);
		errotr = Y-Ydtr;
		EQMtr(nep) = 1/Ntr*sum(sum(errotr.*errotr));
		%fprintf("EQMtr: %f\n",EQMtr(nep));
	end
	A = ABest;
	B = BBest;
	
	%{
	plot(EQMtr);
	hold on;
	plot(EQMvl);
	hold off;
	pause;
	%}
end

function Y = teste(A,B,Xts)
	[N,~] = size(Xts);
	%Adiciona o bias
	Xts = [Xts, ones(N,1)];
	Y = calcSaida(A,B,Xts,N);
end

function Y = calcSaida(A,B,X,N)
	Zin = X*A';
	Z = tanh(Zin);
	Yin = [Z,ones(N,1)]*B';
	Y = tanh(Yin);
end

function alfa = calcAlfa(dJdAOld,dJdBOld,dJdA,dJdB,alfaOld)
	EOld = [dJdAOld(:)' dJdBOld(:)'];
	ENew = [dJdA(:)' dJdB(:)'];
	cosTeta = ENew*EOld'/(norm(ENew)*norm(EOld));
	alfa = alfaOld*(1 +(0.5*cosTeta));
	if alfa >= 1
		alfa = 0.9999;
	end
	%fprintf("alfa: %2.5f\n",alfa);
end