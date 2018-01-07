%{
Classe responsável pela chamada das funções de pré-processamento dos conjuntos de dados
de treinamento e teste das séries temporais.
%}
classdef ProcessaSeries
	methods (Static = true)
		%{
		Função encarregada pelo pré-processamento do conjunto de dados de
		treinamento. Ela é responsável por remover a tendência das séries (quando
		houver), normalizar os dados e gerar as entradas atrasadas.
		Parâmetros
		datasetTreinamento: Conjunto de dados para treinamento;
		lag: Quantidade de atrasos que serão inseridos na MLP;
		Saídas
		Xtr: Conjunto de dados de entrada para a etapa de treinamento;
		Ydtr: Saída desejada para o conjunto Xtr;
		datasetNormTr: Conjunto de dados da etapa de treinamento normalizados;
		%}
		function [Xtr,Ydtr,datasetNormTr] = processaDatasetTreinamento(datasetTreinamento, lag)
			%Remove tendência da serie (se houver) e normaliza
			datasetNormTr = detrend(datasetTreinamento);
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
			%Gera os conjuntos de treinamento
			Xtr=X(:,1:end-1);
			Ydtr=X(:,end);
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
			%Gera os atrasos
			Xts = zeros(size(datasetNormTs,1)-1,lag+1);
			i=1;
			while i <= lag+1
				Xts(i:end,i) = datasetNormTs(1:end-i,1);
				i = i+1;
			end
			%Pega os valores atrasados do treinamento
			i=1;
			while i <=lag
				Xts(1:i,i+1) = datasetNormTr(end-i+1:end,1);
				i = i+1;
			end
			Ydts = datasetTeste(2:end);
		end
	end
end
