function [Xtr,Ydtr,Xvl,Ydvl,Xts] = processaDados(datasetTreinamento, datasetTeste, lag, porcValidacao)
	[Xtr,Ydtr,Xvl,Ydvl,maxTr,datasetNormTr] = processaDatasetTreinamento(datasetTreinamento, lag, porcValidacao);
	Xts = processaDatasetTeste(datasetNormTr, datasetTeste, lag, maxTr);
end

function [Xtr,Ydtr,Xvl,Ydvl,maxTr,datasetNormTr] = processaDatasetTreinamento(datasetTreinamento, lag, porcValidacao)
	%Remove tendência da serie
	datasetNormTr = detrend(datasetTreinamento);
	%Normalização max-min
	maxTr = max(abs(datasetNormTr));
	datasetNormTr = datasetNormTr/maxTr;
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
	%Gera os conjuntos de treinamento e validação
	Xvl=X(1:floor(length(X)*(porcValidacao)),1:end-1);
	Ydvl=X(1:floor(length(X)*(porcValidacao)),end);
	Xtr=X(ceil(length(X)*(porcValidacao)):end,1:end-1);
	Ydtr=X(ceil(length(X)*(porcValidacao)):end,end);
end

function Xts = processaDatasetTeste(datasetNormTr, datasetTeste, lag, maxTr)
	%Remove tendência da série
	datasetNormTs = detrend(datasetTeste);
	%Normalização max-min
	datasetNormTs = datasetNormTs/maxTr;
	%Gera os atrasos
	Xts = zeros(size(datasetNormTs,1),lag+1);
	i=1;
	while i <= lag+1
		Xts(i:end,i) = datasetNormTs(1:end-i+1,1);
		i = i+1;
	end
	%Pega os valores atrasados do treinamento
	i=1;
	while i <=lag
		Xts(1:i,i+1) = datasetNormTr(end-i+1:end,1);
		i = i+1;
	end
end