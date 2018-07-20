%{
Antes de usar a função de pré-processamento foram removidos manualmente
dos arquivos a lista de itens e os indicadores de começo e fim dos dados.
Além disso foi icluído na primeira linha o número de transações.
%}
%{
Função que realiza o pré-processamento dos conjuntos de dados Sparce. Ela
realiza a leitura linha a linha do arquivo a ser processado, sendo cada
linha uma os itens de uma transação que será estudada.
%%Parâmetros%%
dataset: Caminho para o dataset que será pré-processado.
%%Saídas%%
transacoes: struct representando as transações que serão analisadas pelo
algoritmo Apriori.
nroItens: Número total de itens diferentes existentes nas transações.
%}
function [nroItens,transacoes] = preProcessamentoSparse(dataset)
	%Abre o arquivo que vai ser lido.
	fid = fopen(dataset,'r');
	fprintf("Lendo arquivo de entrada\n");
	%Primeira linha do arquivo é o número de itens
	linha = fgetl(fid);
	nroItens = str2double(linha);
	%Segunda linha é o número de transações
	linha = fgetl(fid);
	N = str2double(linha);
	%Inicializa a struct de transações
	transacoes = struct('itens', cell(1,N));
	%Le as demais linhas do arquivo
	i=1;
	while feof(fid) == 0 %checa se chegou ao final do arquivo
		linha = fgetl(fid);
		linha = strsplit(linha, ' ');
		%Cada linha representa os itens de uma transação
		transacoes(i).itens = str2double(linha(1:end-1));
		i=i+1;
	end
	%Fecha o arquivo
	fclose(fid);
end