%{
Classe responsável por representar o método Apriori.
Atributos
nroItens: Número total de itens diferentes existentes nas transações.
nroTransacoes: Número de transações que serão analisadas.
transacoes: Struct que representa o conjunto de transacoes que serão
	analisadas pelo algorítmo. Possui somente o campo itens, o qual
	consiste de um vetor contendo os indices dos itens inclusos naquela
	transação. O id da trasação é representado pelo índice do struct.
minSup: Suporte mímino que será considerado na analize das regras.

Funções
Apriori: Método construtor.
umItemsetsFrequentes: Função que determina os um-itemsets frequentes (L1) e
	seus suportes.
calcSuporte: Função responsável por calcular o suporte de um itemset e
	determianr os itens frequentes (sup > supMin).
geraCandidatos: Função responsável por gerar os novos canditos a partir do
	imteset da etapa anterior.
%}
classdef Apriori < handle
	properties (SetAccess = private)
		nroItens;
		nroTransacoes;
		transacoes;
		minSup;
		%minConf;
	end
	
	methods
		%{
		Método construtor do objeto Apriori
		Parâmetros
		Recebe como parâmetros valores para inicialização dos atributos do
		objeto. Ver descrição da classe.
		%}
		function apriori = Apriori(nroItens,transacoes,minSup)
			apriori.nroItens = nroItens;
			apriori.transacoes = transacoes;
			apriori.nroTransacoes = size(transacoes,2);
			apriori.minSup = minSup;
		end
		
		%{
		
		%}
		function itemsetsFrequentes = executa(apriori)
			%Encontra os um-itemsets frequentes
			itemsetsFrequentes{1} = apriori.umItemsetsFrequentes();
			%Encontra os n-itemses frequentes
			k=2;
			itemsetVazio = 0;
			while itemsetVazio == 0 %para quando o novo itemset for vazio
				[itemsets,itemsetVazio] = apriori.geraCandidatos(itemsetsFrequentes{k-1},k);
				if itemsetVazio == 0
					[itemsets,itemsetVazio] = apriori.calcSuporte(itemsets);
					if itemsetVazio == 0
						itemsetsFrequentes{k} = itemsets;
						k=k+1;
					end
				end
			end
		end	
	end
	
	methods (Access = private)
		%{
		Função que determina os um-itemsets frequentes (L1) e seus
		suportes por meio da varredura do conjunto de transações.
		Saída
		itemsets: struct contendo os iténs e respectivos suportes dos
		um-itemsets.
		%}
		function itemsets = umItemsetsFrequentes(apriori)
			%Estrutura que representará um itemset
			itemsets = struct('itens', cell(1,apriori.nroItens), 'suporte', 0);
			%Econtra o suporte dos itens individuais do um-itemset 
			for i=1:apriori.nroTransacoes
				for j=1:length(apriori.transacoes(i).itens)
					itemsets(apriori.transacoes(i).itens(j)).itens = apriori.transacoes(i).itens(j);
					itemsets(apriori.transacoes(i).itens(j)).suporte = itemsets(apriori.transacoes(i).itens(j)).suporte+(1/apriori.nroTransacoes);
				end
			end
			%Determina quais possuem suporte menor que minSup
			i=1;
			while i <= length(itemsets)
				if itemsets(i).suporte < apriori.minSup
					itemsets(i) = [];
				else
					i=i+1;
				end
			end
		end
		
		%{
		Função responsável por calcular o suporte de um itemset e
		determianr os itens frequentes (sup > supMin).
		Parâmetros
		itemsets: imtemset para o qual o suporte será calculado.
		Saída
		itemsets: itemset atualizado com valor do suporte e apenas itens
		frequentes.
		%}
		function [itemsets,itemsetVazio] = calcSuporte(apriori,itemsets)
			%Calcula o suporte dos itemsets
			for i=1:apriori.nroTransacoes
				for j=1:length(itemsets)
					%Checa se o itemset existe na transação, se sim
					%adiciona a contagem do suporte.
					temp = intersect(apriori.transacoes(i).itens,itemsets(j).itens);
					if length(temp) == length(itemsets(j).itens)
						itemsets(j).suporte = itemsets(j).suporte+(1/apriori.nroTransacoes);
					end
				end
			end
			%Determina quais são frequentes
			i=1;
			while i <= length(itemsets)
				if itemsets(i).suporte < apriori.minSup
					itemsets(i) = [];
				else
					i=i+1;
				end
			end
			%Checa se ficou vazio
			if isempty(itemsets) == 1
				itemsetVazio=1;
			else
				itemsetVazio=0;
			end
		end
	end
	
	methods (Static = true, Access = private)
		%{
		Função responsável por gerar os novos canditos a partir do
		imteset da etapa anterior.
		Parâmetros
		itemsetAnterior: Itemset da iteração anterior (k-1) do algoritmo Apriori.
		k: Número da atual iteração do algoritmo.
		Saídas
		itemsets: itemset com os novos candidatos.
		itemsetVazio: variável boleana que indica se o novo itemset é vazio
		ou não. Utilizada na condição de parada do algorítmo.
		%}
		function [itemsets,itemsetVazio] = geraCandidatos(itemsetAnterior,k)
			itemsets = struct('itens', cell(1,1), 'suporte', 0);
			itemsetVazio = 1; %usado para condição de parada.
			w=1;
			%Compara os itemsets e une aqueles que tem todos os valores
			%iguais exceto o último.
			for i=1:length(itemsetAnterior)-1
				for j=i+1:length(itemsetAnterior)
					if k==2 || all(itemsetAnterior(i).itens(1:end-1) == itemsetAnterior(j).itens(1:end-1)) 
						candidato = union(itemsetAnterior(i).itens, itemsetAnterior(j).itens);
						%Apos a unicao, checa se não viola a propriedade
						%Apriori.
						comb = combnk(candidato,k-1);
						respeita=zeros(1,size(comb,1));
						for m=1:size(comb,1)
							for n=1:length(itemsetAnterior)
								if isequal(itemsetAnterior(n).itens,comb(m,:))
									respeita(1,m) = 1;
									break;
								end
							end
						end
						%Se respeita a pripriedade Apriori, inclui no novo
						%itemset
						if all(respeita) == 1
							itemsetVazio=0;
							itemsets(w).itens = candidato;
							itemsets(w).suporte = 0;
							w=w+1;
						end
					end
				end
			end
		end
	end
end