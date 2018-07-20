%{
Antes de usar a função de pré-processamento o valor dos atributos do
conjunto de dados foi traduzido de palavras para números usando
search-replace da seguinte forma:
	democrat=0, republican=1
	y=1,n=0,?=abstencoes=-1
Ao invés de tratar as abstenções e não posicionamento (representado por ?)
como dados faltantes, estes foram mantido pois a falta de posicionamento de
um deputado pode ser um dado interessante.
%}
%{
Função que realiza o pré-processamento do conjunto de dados Congressional
Voting Records. Ela é responsável por transformar os valores possíveis dos
atributos em itens de transações. Isso é feito associando um índice para
cada possível valor de cada um dos atribútos:
	1. Class Name: 2 (democrat, republican)
		democrat 1
		republican 2
	2. handicapped-infants: 2 (y,n)
		Y 3
		N 4
		? 5
	3. water-project-cost-sharing: 2 (y,n)
		Y 6
		N 7
		? 8
	...
De acordo com essa codificação, cada linha do conjunto de dados é
transformada em uma transação.
%%Parâmetros%%
path: Caminho para o dataset que será pré-processado.
%%Saídas%%
transacoes: struct representando as transações que serão analisadas pelo
algoritmo Apriori.
nroItens: Número total de itens diferentes existentes nas transações. 
%}
function [nroItens,transacoes] = preProcessamentoVotes(path)
	%Carrega o dataset
	dataset = load(path);
	N = size(dataset,1); %número de dados
	ne = size(dataset,2); %número de colunas
	dadosTratados =  zeros(N,size(dataset,2));
	%Transforma cada linha do dataset em transações, transformando os
	%valores possíveis dos atributos em itens.
	for i=1:N
		%Traduz a classe para itens
		if dataset(i,1) == 0
			dadosTratados(i,1) = 1;
		else
			dadosTratados(i,1) = 2;
		end
		k=3;
		%Traduz os demais atributos
		for j=2:ne
			if dataset(i,j) == 1
				dadosTratados(i,j) = k;
			elseif dataset(i,j) == 0
				dadosTratados(i,j) = k+1;
			else
				dadosTratados(i,j) = k+2;
			end
			k = k+3;
		end
	end
	%Salva o número total de itens
	nroItens = k-1;
	%Ordena as transações do maior pro menor
	dadosTratados = sortrows(dadosTratados,1);
	%Passa para a representação que será usada no Apriori
	transacoes = struct('itens', cell(1,N));
	for i=1:N
		transacoes(i).itens = dadosTratados(i,:);
	end
end