%{
Função que realiza o pré-processamento dos conjuntos de dados Sparce
localizados em http://www.i3s.unice.fr/~pasquier/web/?Research_Activities__
_Dataset_Downloads___Benchmark_Datasets.
Parâmetros
dataset: Caminho para o dataset que será pré-processado
Saídas
transacoes: struct representando as transações que serão analisadas pelo
algoritmo Apriori.
%}
function transacoes = preProcessamentoSparse(dataset)
	%Abre o arquivo que vai ser lido.
	fid = fopen(dataset,'r');
	%Primeira linha do arquivo é o número de transações
	linha = fgetl(fid);
	N = str2double(linha);
	%Inicializa a struct de transações
	transacoes = struct('itens', cell(1,N));
	%Le as demais linhas do arquivo
	i=1;
	while feof(fid) == 0 %checa se chegou ao final do arquivo
		linha = fgetl(fid);
		linha = strsplit(linha, ' ');
		transacoes(i).itens = str2double(linha(1:end-1));
		i=i+1;
	end
	%Fecha o arquivo
	fclose(fid);
end