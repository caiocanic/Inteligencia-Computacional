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
function [Xtr,Ydtr,Xvl,Ydvl,Xts,Ydts,media,desvio,p] = processaDados(datasetTreinamento, datasetTeste,porcValidacao)
	%Remove tend�ncia
	x=(1:size(datasetTreinamento,1))';
	p = polyfit(x,datasetTreinamento,1);
	pVal = polyval(p,x);
	datasetTreinamento = datasetTreinamento-pVal;
	x=(1:size(datasetTeste,1))';
	pVal = polyval(p,x);
	datasetTeste = datasetTeste-pVal;
	
	%Normaliza
	media = mean(datasetTreinamento);
	desvio = std(datasetTreinamento);
	datasetTreinamento = (datasetTreinamento-media)/desvio;
	datasetTeste = (datasetTeste-media)/desvio;
	
	%Gera os conjuntos de treinamento e valida��o
	Xtr = datasetTreinamento(1:floor(length(datasetTreinamento)*(1-porcValidacao)));
	Ydtr = datasetTreinamento(2:floor(length(datasetTreinamento)*(1-porcValidacao)+1));
	Xvl = datasetTreinamento(ceil(length(datasetTreinamento)*(1-porcValidacao)):end-1);
	Ydvl = datasetTreinamento(ceil(length(datasetTreinamento)*(1-porcValidacao))+1:end);
	
	%Gera o conjunto de teste
	Xts = datasetTeste(1:end-1);
	Ydts = datasetTeste(2:end);
end