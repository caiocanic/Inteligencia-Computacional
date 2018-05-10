%Implementação do perceptron com função de ativação sigmoid ou softmax
%Possível utilizar validação e passo ótimo
function [A,vErroTr,vErroVl,nEp] = perceptron(Xtr, Ydtr, Xvl, Ydvl,alfaInicial,nEpocasMax,funcao)
	%Parâmetros internos
	nVlMax = 20;
	
	%Inicializações
	vErroVl = [];
	nVal = 0;
	nEp = 0;
	[Ntr,ns] = size(Ydtr);
	Xtr = [Xtr,ones(Ntr,1)];
	ne = size(Xtr,2);
	%Inicializa os pesos
	%
	a = -0.2;
	b = 0.2;
	A = a + (b-a).*rand(ns,ne);
	%
	%Inicialização fixa dos pesos para testes
	%A = zeros(ns,ne)+0.1;
	
	%Cálculos do perceptron
	%Calcula a saída para conjunto de treinamento
	[~,erroTr] = calcSaida(Xtr,Ydtr,A,funcao);
	EQMtr = 1/Ntr*sum(sum(erroTr.*erroTr));
	vErroTr = EQMtr;
	%Calcula a saída para conjunto de validação
	if ~isempty(Xvl)
		Nvl = size(Xvl,1);
		Xvl=[Xvl,ones(Nvl,1)];
		[~,erroVl] = calcSaida(Xvl,Ydvl,A,funcao);
		EQMvl = 1/Nvl*sum(sum(erroVl.*erroVl));
		EQMvlBest = EQMvl;
		vErroVl = EQMvl;
	end
	%loop de treinamento
	while EQMtr>1e-6 && nEp<nEpocasMax && nVal < nVlMax
		dJdA = grad(Xtr,Ydtr,A,Ntr,funcao);
		%Checa o alpha
		if isempty(alfaInicial)
			%Calcula o alfa ótimo
			alfa = calcAlfa(Xtr,Ydtr,-dJdA,A,Ntr,funcao);
		else
			alfa = alfaInicial;
		end
		%Atualiza os pessos
		A = A - alfa*dJdA;
		%Recalcula as saídas
		[~,erroTr] = calcSaida(Xtr,Ydtr,A,funcao);
		EQMtr = 1/Ntr*sum(sum(erroTr.*erroTr));
		vErroTr = [vErroTr;EQMtr];
		%Checa se havera validação
		if ~isempty(Xvl)
			[~,erroVl] = calcSaida(Xvl,Ydvl,A,funcao);
			EQMvl = 1/Nvl*sum(sum(erroVl.*erroVl)); 
			vErroVl = [vErroVl;EQMvl];
			%Checa se o erro de validação sobe, para determinar a parada
			if EQMvl >= EQMvlBest
				nVal = nVal + 1;
			else
				EQMvlBest = EQMvl;
				Avl = A;
				nVal = 0;
			end
		end
		nEp = nEp +1;
	end
	
	%Se presente, retorna a melhor matriz de pesos da validação
	if ~isempty(Xvl)
		A = Avl;
	end
end