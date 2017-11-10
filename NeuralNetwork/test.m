function [A,B,Y] = test()
	lag = 10;
	porcValidacao = 0.3;
	datasetTreinamento = load("Dataset_series/serie2_trein.txt");
	datasetTeste = load("Dataset_series/serie2_test.txt");
	[Xtr,Ydtr,Xvl,Ydvl] = processaDatasetTreinamento(datasetTreinamento, lag,porcValidacao);
	Xts = processaDatasetTest(datasetTreinamento, datasetTeste, lag);
	h=4;
	[A,B,Y] = mlp(Xtr,Ydtr,Xvl,Ydvl,Xts,h);
	
	%{
	plot(datasetTeste,'DisplayName','dataset');
	hold on;
	plot(Y,'DisplayName','Y');
	hold off;
	%}
end

function Xts = processaDatasetTest(datasetTreinamento, datasetTeste, lag)
	%Gera os atrasos
	Xts = zeros(size(datasetTeste,1),lag+1);
	i=1;
	while i <= lag+1
		Xts(i:end,i) = datasetTeste(1:end-i+1,1);
		i = i+1;
	end
	%Pega os valores atrasados do treinamento
	i=1;
	while i <=lag
		Xts(1:i,i+1) = datasetTreinamento(end-i+1:end,1);
		i = i+1;
	end
end

function [Xtr,Ydtr,Xvl,Ydvl] = processaDatasetTreinamento(datasetTreinamento, lag, porcValidacao)
	%normalização min-max
	datasetNorm = datasetTreinamento/max(abs(datasetTreinamento));
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
	%randomiza a ordem das entradas
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