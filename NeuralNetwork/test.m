function [A,B,Y] = test()
	%Xtr = [0 0; 0 1; 1 0; 1 1];
	%Yd = [0;1;1;0];
	%Xts = [0 0; 0 1; 1 0; 1 1];
	lag = 5;
	porcentagemValidacao = 0.3;
	datasetTreinamento = load("Dataset_series/serie2_trein.txt");
	[Xtr,Ydtr,Xvl,Ydvl] = processDatasetTreinamento(datasetTreinamento, lag,porcentagemValidacao);
	Xts = load("Dataset_series/serie2_test.txt");
	h=5;
	[A,B,Y] = mlp(Xtr,Ydtr,Xvl,Ydvl,Xts,h);
	
	%{
	plot(dataset,'DisplayName','dataset');
	hold on;
	plot(Y,'DisplayName','Y');
	hold off;
	%}
end

function [Xtr,Ydtr,Xvl,Ydvl] = processDatasetTreinamento(dataset, lag, porcentagemValidacao)
	%normalização min-max
	datasetNorm = dataset/max(abs(dataset));
	%Adiciona os lags e a saída desejada
	i=1;
	temp=datasetNorm(1:end-1);
	X = zeros(length(temp),lag+2);
	while i <= lag+1
		X(:,i) = temp;
		temp = [0;temp(1:end-1)];
		i = i+1;
	end
	X(:,end) = dataset(2:end);
	%randomiza a ordem das entradas
	[m,~] = size(X);
	idx = randperm(m);
	temp=X;
	for i=1:m
		X(idx(i),:)=temp(i,:);
	end
	%Gera os conjuntos de treinamento e validação
	Xvl=X(1:floor(length(X)*(porcentagemValidacao)),1:end-1);
	Ydvl=X(1:floor(length(X)*(porcentagemValidacao)),end);
	
	Xtr=X(ceil(length(X)*(porcentagemValidacao)):end,1:end-1);
	Ydtr=X(ceil(length(X)*(porcentagemValidacao)):end,end);
end