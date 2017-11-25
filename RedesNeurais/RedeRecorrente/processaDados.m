%{
Função responsável pela chamada das funções de pré-processamento dos conjuntos de dados
de treinamento e teste. Considera número de entradas externas = 1;
Parâmetros
datasetTreinamento: Conjunto de dados para treinamento;
datasetTeste: Conjunto de dados para teste;
porcValidacao: Porcentagem do conjunto de dados de treinamento que será
dedicada a validação;
Saídas
Xtr: Conjunto de dados de entrada para a etapa de treinamento;
Ydtr: Saída desejada para o conjunto Xtr;
Xvl: Conjunto de dados para a etapa de validação;
Ydvl: Saída desejada para o conjunto Xvl;
Xts: Conjunto de dados de entrada para a etapa de teste;
%}
function [Xtr,Ydtr,Xvl,Ydvl,Xts,Ydts] = processaDados(datasetTreinamento, datasetTeste,porcValidacao)
	[Xtr,Ydtr,Xvl,Ydvl] = processaDatasetTreinamento(datasetTreinamento, porcValidacao);
	[Xts,Ydts] = processaDatasetTeste(datasetTeste);
end

%{
Função encarregada pelo pré-processamento do conjunto de dados de
treinamento. Ela é responsável por remover a tendência das séries (quando
houver) e normalizar os dados. Além disso a
função separa parte do conjunto de treinamento para a validação.
Parâmetros
datasetTreinamento: Conjunto de dados para treinamento;
porcValidacao: Porcentagem do conjunto de dados de treinamento que será
dedicada a validação;
Saídas
Xtr: Conjunto de dados de entrada para a etapa de treinamento;
Ydtr: Saída desejada para o conjunto Xtr;
Xvl: Conjunto de dados para a etapa de validação;
Ydvl: Saída desejada para o conjunto Xvl;
%}
function [Xtr,Ydtr,Xvl,Ydvl] = processaDatasetTreinamento(datasetTreinamento, porcValidacao)
	%Remove tendência da serie (se houver) e normaliza
	datasetNormTr = detrend(datasetTreinamento);
	%Gera os conjuntos de treinamento e validação
	Xtr = datasetNormTr(1:floor(length(datasetNormTr)*(1-porcValidacao)));
	Ydtr = datasetNormTr(2:floor(length(datasetNormTr)*(1-porcValidacao)+1));
	Xvl = datasetNormTr(ceil(length(datasetNormTr)*(1-porcValidacao)):end-1);
	Ydvl = datasetNormTr(ceil(length(datasetNormTr)*(1-porcValidacao))+1:end);
end

%{
Função encarregada pelo pré-processamento do conjunto de dados de
teste. Ela é responsável por remover a tendência das séries (quando
houver) e normalizar os dados.
Parâmetros
datasetTeste: Conjunto de dados para teste;
Saídas
Xts: Conjunto de dados de entrada para a etapa de teste;
Ydts: Saída desejada para Xts;
%}
function [Xts,Ydts] = processaDatasetTeste(datasetTeste)
	%Remove tendência da série (se houver) e normaliza
	datasetNormTs = detrend(datasetTeste);
	%Gera o conjunto de teste
	Xts = datasetNormTs(1:end-1);
	Ydts = datasetNormTs(2:end);
end