%Função para normalizar os dados e gerar conjunto de validação
function [Xtr,Ydtr,Xvl,Ydvl,Xts,Ydts] = processaDados(treinamento,teste,porcValidacao)
	[Xtr,Ydtr,Xvl,Ydvl,media,desvio] = processaTreinamento(treinamento,porcValidacao);
	[Xts,Ydts] = processaTeste(teste,media,desvio);
end

%Normaliza o treinamento usando zscores e separa o conjunto de validação se
%solicitado
function [Xtr,Ydtr,Xvl,Ydvl,media,desvio] = processaTreinamento(treinamento,porcValidacao)
	Ntr = size(treinamento,1);
	%Separa a saída desejada
	classesTr = treinamento(:,end);
	nroClasses = max(classesTr);
	Y = zeros(Ntr,nroClasses);
	%Rotula as classes
	for i=1:Ntr
		Y(i,classesTr(i)) = 1;
	end
	%Normaliza os dados
	X = treinamento(:,1:end-1);
	ne = size(X,2);
	media = mean(X);
	desvio = std(X);
	for i=1:ne
		X(:,i) = (X(:,i)-media(i))/desvio(i);
	end
	%Se pedido, separa em treinamento e validação
	if porcValidacao > 0
		%Randomiza a ordem dos dados
		dados = [X,Y];
		idx = randperm(Ntr);
		temp=dados;
		for i=1:Ntr
			dados(idx(i),:)=temp(i,:);
		end
		Xvl=dados(1:floor(length(dados)*(porcValidacao)),1:end-nroClasses);
		Ydvl=dados(1:floor(length(dados)*(porcValidacao)),end-nroClasses+1:end);
		Xtr=dados(ceil(length(dados)*(porcValidacao)):end,1:end-nroClasses);
		Ydtr=dados(ceil(length(dados)*(porcValidacao)):end,end-nroClasses+1:end);
	else
		Xvl = [];
		Ydvl = [];
		Xtr = X;
		Ydtr = Y;
	end
end

%Normaliza o conjunto de teste usando zscores. Utiliza a média e o desvio
%do conjunto de treinamento.
function [Xts,Ydts] = processaTeste(teste,media,desvio)
	Nts = size(teste,1);
	%Separa a saída desejada
	classesTs = teste(:,end);
	nroClasses = max(classesTs);
	Ydts = zeros(Nts,nroClasses);
	%Rotula as classes
	for i=1:Nts
		Ydts(i,classesTs(i)) = 1;
	end
	%Normaliza o treinamento
	Xts = teste(:,1:end-1);
	ne = size(Xts,2);
	for i=1:ne
		Xts(:,i) = (Xts(:,i)-media(i))/desvio(i);
	end
end