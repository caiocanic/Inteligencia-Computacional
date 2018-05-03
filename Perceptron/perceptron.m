function [A,vErroTr,vErroVl] = perceptron(Xtr, Ydtr, Xvl, Ydvl)
	%Parâmetros internos
	nVlMax = 15;
	alfa=1;
	%Se não existe validação, define o número máximo de épocas
	if isempty(Xvl)
		nEpocasMax = 50000;
		vErroVl = [];
	else
		nEpocasMax = 1e30;
	end

	[Ntr,ns] = size(Ydtr);
	Xtr = [Xtr,ones(Ntr,1)];
	ne = size(Xtr,2);
	%Inicializar os pesos
	a = -0.2;
	b = 0.2;
	A = a + (b-a).*rand(ns,ne);
	%Calcula a saída para conjunto de treinamento
	[~,erroTr] = calcSaida(Xtr,Ydtr,A);
	EQMtr = 1/Ntr*sum(sum(erroTr.*erroTr));
	vErroTr = EQMtr;
	%Calcula a saída para conjunto de validação
	if ~isempty(Xvl)
		Nvl = size(Xvl,1);
		Xvl=[Xvl,ones(Nvl,1)];
		[~,erroVl] = calcSaida(Xvl,Ydvl,A);
		EQMvl = 1/Nvl*sum(sum(erroVl.*erroVl));
		EQMvlBest = EQMvl;
		vErroVl = EQMvl;
	end

	nVal = 0;
	while EQMtr>1e-6 && nEpocasMax>0 && nVal < nVlMax
		dJdA = grad(Xtr,Ydtr,A,Ntr);
		%Calcula o alfa ótimo
		alfa = calcAlfa(Xtr,Ydtr,-dJdA,A,Ntr);
		A = A - alfa*dJdA;
		[~,erroTr] = calcSaida(Xtr,Ydtr,A);
		EQMtr = 1/Ntr*sum(sum(erroTr.*erroTr));
		vErroTr = [vErroTr;EQMtr];
		if ~isempty(Xvl)
			[~,erroVl] = calcSaida(Xvl,Ydvl,A);
			EQMvl = 1/Nvl*sum(sum(erroVl.*erroVl)); 
			vErroVl = [vErroVl;EQMvl];
			if EQMvl >= EQMvlBest
				nVal = nVal + 1;
			else
				EQMvlBest = EQMvl;
				Avl = A;
				nVal = 0;
			end
		end
		nEpocasMax = nEpocasMax -1;
	end
	%Retorna a melhor matriz de pesos da validação
	if ~isempty(Xvl)
		A = Avl;
	end
end