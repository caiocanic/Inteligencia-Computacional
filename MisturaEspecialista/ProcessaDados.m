%{
Classe de funções estáticas uilizadas no pré-processamento.
Funções
achaLag: Função responsável por achar o número de atrasos ideal para a
	entrada.
processaTreinamento: Função responsável pelo pré-processamento do
	treinamento. Gera os conjuntos de treinamento e validação e normaliza
	os dados via z-scores.
processaTeste: Função responsável pelo pré-processamento do conjunto de
	teste. Realiza normalização z-scores a partir da media e desvio do
	conjunto de treinamento.
geraKFolds: Função responsável por separar os dados em k partições para a
	validação cruzada k-fold.
%}
classdef ProcessaDados
	methods (Static = true)
		%{
		Função responsável por achar o número de atrasos ideal para a
		entrada.
		Parâmetros
		dados: Conjunto de dados que será analisado;
		lagMax: Lag máximo permitido, limita a dimensão da entrada.
		Saída:
		lag: Número ideal de lags para o conjunto de dados.
		%}
		function lag = achaLag(dados,lagMax)
			%Determina os lags possiveis por meio da correlação
			coef = zeros(lagMax,1);
			for i=1:lagMax
				%Calcula a correlação de x(i) com x(i+1)
				temp = corrcoef(dados(i:end-1),dados(i+1:end)); 
				coef(i,1) = temp(1,2);
			end
			%Deixa em modulo pois interessa a menor correlação, positiva ou
			%negativa
			coef = abs(coef);
			%Acha a menor correlação, será o lag utilizado
			[~,lag] = min(coef);
		end
		
		%{
		Função responsável pelo pré-processamento do treinamento. Gera os
		conjuntos de treinamento e validação e normaliza os dados via
		z-scores.
		Parâmetros
		dadosTreinamento: Conjunto de dados de treinamento.
		lag: Número de atrasos desejado na entrada.
		porcValidacao: Porcentagem do conjunto de treinamento que será
			dedicada a valdação.
		Saídas
		Xtr: Conjunto de dados de entrada do treinamento.
		Ydtr: Saída desejada para os conjunto de dados do treinamento.
		Xvl: Conjunto de dados de entrada para a validação.
		Ydvl: Saída desejada para o conjunto de dados da validação.
		media: media do conjunto de treinamento, usada na normalização do
			teste.
		desvio: desvio padrão do conjunto de treinamento, usado na
			normalização do testes.
		%}
		function [Xtr,Ydtr,Xvl,Ydvl,media,desvio] = processaTreinamento(dadosTreinamento,lag,porcValidacao)
			%Adiciona os lags e a saída desejada
			i=1;
			temp=dadosTreinamento(1:end-1);
			X = zeros(length(temp),lag+2);
			while i <= lag+1
				X(:,i) = temp;
				temp = [0;temp(1:end-1)];
				i = i+1;
			end
			X(:,end) = dadosTreinamento(2:end);
			%Randomiza a ordem das entradas
			[m,~] = size(X);
			idx = randperm(m);
			temp=X;
			for i=1:m
				X(idx(i),:)=temp(i,:);
			end
			%Gera os conjuntos de treinamento e validação
			Xvl=X(1:floor(length(X)*(porcValidacao)),1:end-1);
			Ydvl=X(1:floor(length(X)*(porcValidacao)),end);
			Xtr=X(ceil(length(X)*(porcValidacao)):end,1:end-1);
			Ydtr=X(ceil(length(X)*(porcValidacao)):end,end);
			%Normaliza os dados
			media = mean(Xtr(:,1));
			desvio = std(Xtr(:,1));
			Xtr = (Xtr-media)/desvio;
			Xvl = (Xvl-media)/desvio;
		end
		
		%{
		Função responsável pelo pré-processamento do conjunto de teste.
		Realiza normalização z-scores a partir da media e desvio do
		conjunto de treinamento.
		Parâmetros
		dadosTreinamento: Conjunto de dados de treinamento, usado para as
			entradas atrasadas.
		dadosTeste: Conjunto de dados de testes.
		lag: Número de atrasos desejado na entrada.
		media: media do conjunto de treinamento.
		desvio: desvio padrão do conjunto de treinamento.
		Saídas
		Xts: Conjunto de dados de entrada para o teste.
		%}
		function Xts = processaTeste(dadosTreinamento,dadosTeste,lag,media,desvio)
			%Gera os atrasos
			Xts = zeros(size(dadosTeste,1),lag+1);
			i=1;
			while i <= lag+1
				Xts(i:end,i) = dadosTeste(1:end-i+1,1);
				i = i+1;
			end
			%Pega os valores atrasados do treinamento
			i=1;
			while i <=lag
				Xts(1:i,i+1) = dadosTreinamento(end-i+1:end,1);
				i = i+1;
			end
			%Normaliza os dados
			Xts = (Xts-media)/desvio;
		end
		
		%{
		Função responsável por separar os dados em k partições para a
		validação cruzada k-fold.
		Parâmetros
		dados: Conjunto de dados a ser particionado.
		k: Número de partições que serão geradas.
		Saída
		kFolds: Partições separadas em um cell array.
		%}
		function kFolds = geraKFolds(dados,k)
			%Inicializa as partições vazias
			kFolds = cell(1,k);
			%Arredonda para baixo, para que as partições tenham sempre o
			%mesmo tamanho, alguns dados são descartados.
			tamanho = floor(size(dados,1)/k);
			%Embaralha os dados
			dados = dados(randperm(size(dados,1)),:);
			%Gera as partições
			for i=1:k
				kFolds{i} = dados(1+((i-1)*tamanho):tamanho*i);
			end
		end
	end
end