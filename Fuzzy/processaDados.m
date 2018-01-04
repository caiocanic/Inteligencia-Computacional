%{
Função responsável pela chamada das funções de pré-processamento dos conjuntos de dados
de treinamento e teste.
Parâmetros
datasetTreinamento: Conjunto de dados para treinamento;
datasetTeste: Conjunto de dados para teste;
lag: Quantidade de entradas atrasadas;
Saídas
Xtr: Conjunto de dados de entrada para a etapa de treinamento;
Ydtr: Saída desejada para o conjunto Xtr;
Xts: Conjunto de dados de entrada para a etapa de teste;
Ydts: Saída esperada do conjunto Yts;
%}
function [Xtr,Ydtr,Xvl,Ydvl,Xts,Ydts] = processaDados(datasetTreinamento, datasetTeste, lag, porcValidacao)
	[Xtr,Ydtr,Xvl,Ydvl,datasetNormTr] = processaDatasetTreinamento(datasetTreinamento, lag, porcValidacao);
	[Xts,Ydts] = processaDatasetTeste(datasetNormTr, datasetTeste, lag);
end

%{
Função encarregada pelo pré-processamento do conjunto de dados de
treinamento. Ela é responsável por remover a tendência das séries (quando
houver), normalizar os dados e gerar as entradas atrasadas.
Parâmetros
datasetTreinamento: Conjunto de dados para treinamento;
lag: Quantidade de entradas atrasadas;
Saídas
Xtr: Conjunto de dados de entrada para a etapa de treinamento;
Ydtr: Saída desejada para o conjunto Xtr;
datasetNormTr: Conjunto de dados da etapa de treinamento normalizados;
%}
function [Xtr,Ydtr,Xvl,Ydvl,datasetNormTr] = processaDatasetTreinamento(datasetTreinamento, lag, porcValidacao)
	%Remove tendência da serie (se houver) e normaliza
	datasetNormTr = detrend(datasetTreinamento);
	datasetNormTr = (datasetNormTr - min(datasetNormTr))/(max(datasetNormTr) - min(datasetNormTr));
	%Adiciona os lags e a saída desejada
	i=1;
	temp=datasetNormTr(1:end-1);
	X = zeros(length(temp),lag+2);
	while i <= lag+1
		X(:,i) = temp;
		temp = [0;temp(1:end-1)];
		i = i+1;
	end
	X(:,end) = datasetTreinamento(2:end);
	%Randomiza a ordem das entradas
	[m,~] = size(X);
	idx = randperm(m);
	temp=X;
	for i=1:m
		X(idx(i),:)=temp(i,:);
	end
	%Gera os conjuntos de treinamento e valida��o
	Xvl=X(1:floor(length(X)*(porcValidacao)),1:end-1);
	Ydvl=X(1:floor(length(X)*(porcValidacao)),end);
	Xtr=X(ceil(length(X)*(porcValidacao)):end,1:end-1);
	Ydtr=X(ceil(length(X)*(porcValidacao)):end,end);
end

%{
Função encarregada pelo pré-processamento do conjunto de dados de
teste. Ela é responsável por remover a tendência das séries (quando
houver), normalizar os dados e gerar as entradas atrasadas vindas do
treinamento.
Parâmetros
datasetNormTr: Conjunto de dados da etapa de treinamento normalizados;
datasetTeste: Conjunto de dados para teste;
lag: Quantidade de atrasos que serão inseridos na MLP;
Saídas
Xts: Conjunto de dados de entrada para a etapa de teste;
%}
function [Xts,Ydts] = processaDatasetTeste(datasetNormTr, datasetTeste, lag)
	%Remove tendência da série (se houver) e normaliza
	datasetNormTs = detrend(datasetTeste);
	datasetNormTs = (datasetNormTs - min(datasetNormTs))/(max(datasetNormTs) - min(datasetNormTs));
	%Gera os atrasos
	X = zeros(size(datasetNormTs,1)-1,lag+2);
	i=1;
	while i <= lag+1
		X(i:end,i) = datasetNormTs(1:end-i,1);
		i = i+1;
	end
	%Pega os valores atrasados do treinamento
	i=1;
	while i <=lag
		X(1:i,i+1) = datasetNormTr(end-i+1:end,1);
		i = i+1;
	end
	%Adiciona a saída desejada
	X(:,end) = datasetTeste(2:end);
	%Randomiza a ordem das entradas
	[m,~] = size(X);
	idx = randperm(m);
	temp=X;
	for i=1:m
		X(idx(i),:)=temp(i,:);
	end
	Xts = X(:,1:end-1);
	Ydts = X(:,end);
end