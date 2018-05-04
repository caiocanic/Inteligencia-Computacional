%Implementação do perceptron do função de ativação sigmoid
%Possível utilizar validação e passo ótimo
function [A,vErroTr,vErroVl] = perceptron(Xtr, Ydtr, Xvl, Ydvl,alfa,nEpocasMax)
	%Parâmetros internos
	nVlMax = 15;
	%Se existe validação, retira o limite de número de épocas
	if ~isempty(Xvl)
		nEpocasMax = 1e30;
	end
	
	%Inicializações
	vErroVl = [];
	nVal = 0;
	[Ntr,ns] = size(Ydtr);
	Xtr = [Xtr,ones(Ntr,1)];
	ne = size(Xtr,2);
	%Inicializa os pesos
	%{
	a = -0.2;
	b = 0.2;
	A = a + (b-a).*rand(ns,ne);
	%}
	%Inicialização fixa dos pesos para teste
	A = zeros(ns,ne)+0.1;
	
	%Cálculos do perceptron
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
	while EQMtr>1e-6 && nEpocasMax>0 && nVal < nVlMax
		dJdA = grad(Xtr,Ydtr,A,Ntr);
		%Calcula o alfa ótimo
		%alfa = calcAlfa(Xtr,Ydtr,-dJdA,A,Ntr);
		%Atualiza os pessos
		A = A - alfa*dJdA;
		%Recalcula as saídas
		[~,erroTr] = calcSaida(Xtr,Ydtr,A);
		EQMtr = 1/Ntr*sum(sum(erroTr.*erroTr));
		vErroTr = [vErroTr;EQMtr];
		%Checa se havera validação
		if ~isempty(Xvl)
			[~,erroVl] = calcSaida(Xvl,Ydvl,A);
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
		nEpocasMax = nEpocasMax -1;
	end
	
	%Se presente, retorna a melhor matriz de pesos da validação
	if ~isempty(Xvl)
		A = Avl;
	end
end