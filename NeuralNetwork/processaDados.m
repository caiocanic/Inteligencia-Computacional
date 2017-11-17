function [Xtr,Ydtr,Xvl,Ydvl,Xts] = processaDados(datasetTreinamento, datasetTeste, lag, porcValidacao)
	maxTr = max(abs(datasetTreinamento));
	[Xtr,Ydtr,Xvl,Ydvl] = processaDatasetTreinamento(datasetTreinamento, lag, porcValidacao,maxTr);
	Xts = processaDatasetTeste(datasetTreinamento, datasetTeste, lag, maxTr);
end

function [Xtr,Ydtr,Xvl,Ydvl] = processaDatasetTreinamento(datasetTreinamento, lag, porcValidacao, maxTr)
	%Normalização max-min
	datasetNorm = datasetTreinamento/maxTr;
	%Adiciona os lags e a saída desejada
	i=1;
	temp=datasetNorm(1:end-1);
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
	%Gera os conjuntos de treinamento e validação
	Xvl=X(1:floor(length(X)*(porcValidacao)),1:end-1);
	Ydvl=X(1:floor(length(X)*(porcValidacao)),end);
	Xtr=X(ceil(length(X)*(porcValidacao)):end,1:end-1);
	Ydtr=X(ceil(length(X)*(porcValidacao)):end,end);
end

function Xts = processaDatasetTeste(datasetTreinamento, datasetTeste, lag, maxTr)
	%Normalização max-min
	datasetNorm = datasetTeste/maxTr;
	datasetTreinamento = datasetTreinamento/maxTr;
	%Gera os atrasos
	Xts = zeros(size(datasetNorm,1),lag+1);
	i=1;
	while i <= lag+1
		Xts(i:end,i) = datasetNorm(1:end-i+1,1);
		i = i+1;
	end
	%Pega os valores atrasados do treinamento
	i=1;
	while i <=lag
		Xts(1:i,i+1) = datasetTreinamento(end-i+1:end,1);
		i = i+1;
	end
end