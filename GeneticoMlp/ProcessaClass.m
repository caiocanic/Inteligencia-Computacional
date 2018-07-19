classdef ProcessaClass
	properties (Constant)
		porcValidacao=0.3;
	end
	methods (Static = true)
		function [Xtr,Ydtr,Xvl,Ydvl,maxTr,minTr] = processaDatasetTreinamento(datasetTreinamento,nroClasses)
			maxTr = max(datasetTreinamento);
			minTr = min(datasetTreinamento);
			datasetNormTr = datasetTreinamento;
			%Normaliza
			for i=1:size(datasetTreinamento,2)-nroClasses
				datasetNormTr(:,i)=(datasetTreinamento(:,i)-minTr(i))/(maxTr(i)-minTr(i));
			end
			X = datasetNormTr;
			%Randomiza a ordem das entradas
			[m,~] = size(X);
			idx = randperm(m);
			temp=X;
			for i=1:m
				X(idx(i),:)=temp(i,:);
			end
			%Gera os conjuntos de treinamento e validação
			Xvl=X(1:floor(length(X)*(ProcessaClass.porcValidacao)),1:end-nroClasses);
			Ydvl=X(1:floor(length(X)*(ProcessaClass.porcValidacao)),end-nroClasses+1:end);
			Xtr=X(ceil(length(X)*(ProcessaClass.porcValidacao)):end,1:end-nroClasses);
			Ydtr=X(ceil(length(X)*(ProcessaClass.porcValidacao)):end,end-nroClasses+1:end);
		end
		
		function [Xts,Ydts] = processaDatasetTeste(datasetTeste,nroClasses,maxTr,minTr)
			datasetNormTs = datasetTeste;
			%Normaliza
			for i=1:size(datasetTeste,2)-nroClasses
				datasetNormTs(:,i)=(datasetTeste(:,i)-minTr(i))/(maxTr(i)-minTr(i));
			end
			X = datasetNormTs;
			%Gera o conjunto de teste
			Xts = X(:,1:end-nroClasses);
			Ydts = X(:,end-nroClasses+1:end);
		end
	end
end