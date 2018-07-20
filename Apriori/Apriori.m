%{
Classe responsável por representar o método Apriori.
%Atributos%
nroItens: Número total de itens diferentes existentes nas transações.
nroTransacoes: Número de transações que serão analisadas.
transacoes: Struct que representa o conjunto de transacoes que serão
	analisadas pelo algorítmo. Possui somente o campo itens, o qual
	consiste de um vetor contendo os indices dos itens inclusos naquela
	transação. O id da trasação é representado pelo índice do struct.
minSup: Suporte mímino que será considerado na analize das regras.
minConf: Confiança mínima para que uma regra seja considerada forte.
itemsetsFrequentes: Armazena os itemsetsFrequentes encontrados pelo
	algoritmo.
regras: Armazena as regras de associação encontradas pelo algoritmo.
%Funções%
Apriori: Método construtor.
executa: Função que executa a rotina principal do algoritmo Apriori.
umItemsetsFrequentes: Função que determina os um-itemsets frequentes (L1) e
	seus suportes.
calcSuporte: Função responsável por calcular o suporte de um itemset e
	determianr os itens frequentes (sup > supMin).
geraCandidatos: Função responsável por gerar os novos canditos a partir do
	imteset da etapa anterior.
checaSup: Função utilizada para determinar se o suporte de um item é menor
	do que minSup. Através disso determina quais são os itens frequentes,
	eliminando os que não são.
geraRegras: Função responsável por gerar as regras de associação a partir dos
	itensets frequentes determinados pelo Apriori. Somente as regras fortes
	(confianca >= minConf) são incluídas.
achaSuporte: Função que localiza o itemset A dentro do conjunto de itemsets e
	retorna seu suporte.
sortRegras: Função para ordernar as regras de forma decrescente com base no
	suporte e confiança
%}
classdef Apriori < handle
	properties (SetAccess = private)
		nroItens;
		nroTransacoes;
		transacoes;
		minSup;
		minConf;
		itemsetsFrequentes;
		regras;
	end
	
	methods
		%{
		Método construtor do objeto Apriori
		Parâmetros
		Recebe como parâmetros valores para inicialização dos atributos do
		objeto. Ver descrição da classe.
		%}
		function apriori = Apriori(nroItens,transacoes,minSup,minConf)
			apriori.nroItens = nroItens;
			apriori.transacoes = transacoes;
			apriori.nroTransacoes = size(transacoes,2);
			apriori.minSup = minSup;
			apriori.minConf = minConf;
		end
		
		%{
		Função que executa a rotina principal do algoritmo Apriori.
		Saída
		itemsetsFrequentes: Todos os k-itemsets frequentes determinados
		pelo algoritmo.
		%}
		function [itemsetsFrequentes,regras] = executa(apriori)
			%Encontra os um-itemsets frequentes (L1)
			fprintf("Encontrando um-itemsets frequentes\n");
			[itemsetsFrequentes{1},itemsetVazio] = apriori.umItemsetsFrequentes();
			%Encontra os k-itemsets frequentes (Lks)
			k=2;
			while itemsetVazio == 0 %para quando o novo itemset for vazio
				fprintf("Encontrando %d-itemsets frequentes\n",k);
				%Gera os candidatos (Ck), se existir
				[itemsets,itemsetVazio] = apriori.geraCandidatos(itemsetsFrequentes{k-1},k);
				if itemsetVazio == 0
					%Encontra Lk, se existir
					[itemsets,itemsetVazio] = apriori.calcSuporte(itemsets);
					if itemsetVazio == 0
						itemsetsFrequentes{k} = itemsets;
						k=k+1;
					else
						fprintf("%d-itemsets frequentes vazio\n",k);
						fprintf("Finalizado Apriori\n");
						k=k-1;
					end
				else
					fprintf("%d-itemsets frequentes vazio\n",k);
					fprintf("Finalizado Apriori\n");
					k=k-1;
				end
			end
			apriori.itemsetsFrequentes = itemsetsFrequentes;
			%Encontrados os k-itemsets frequentes, gera as regras de
			%associação
			regras = apriori.geraRegras(itemsetsFrequentes,k);
			apriori.regras = regras;
		end
	end
	
	methods (Access = private)
		%{
		Função que determina os um-itemsets frequentes (L1) e seus
		suportes por meio da varredura do conjunto de transações.
		Saída
		itemsets: struct contendo os iténs e respectivos suportes dos
			um-itemsets.
		itemsetVazio: variável booleana usada para determinar se a condição
			de parada foi atingida.
		%}
		function [itemsets,itemsetVazio] = umItemsetsFrequentes(apriori)
			%Estrutura que representará um itemset
			itemsets = struct('itens', cell(1,apriori.nroItens), 'suporte', 0);
			%Econtra o suporte dos itens individuais do um-itemset 
			fprintf("Calculando suporte\n");
			for i=1:apriori.nroTransacoes
				%fprintf("%.2f%%\n",i/apriori.nroTransacoes*100);
				for j=1:length(apriori.transacoes(i).itens)
					%Cria um-itemset com aquele item
					itemsets(apriori.transacoes(i).itens(j)).itens = apriori.transacoes(i).itens(j);
					%Conta o suporte
					itemsets(apriori.transacoes(i).itens(j)).suporte = itemsets(apriori.transacoes(i).itens(j)).suporte+(1/apriori.nroTransacoes);
				end
			end
			%Checa quais itens são frequentes ou não. Elimina os
			%infrequentes.
			[itemsets,itemsetVazio] = apriori.checaSup(itemsets,apriori.minSup);
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
			fprintf("Calculando suporte\n");
			for i=1:apriori.nroTransacoes
				%fprintf("%.2f%%\n",i/apriori.nroTransacoes*100);
				for j=1:length(itemsets)
					%Checa se o itemset existe na transação, se sim
					%adiciona a contagem do suporte.
					temp = intersect(apriori.transacoes(i).itens,itemsets(j).itens);
					if length(temp) == length(itemsets(j).itens)
						itemsets(j).suporte = itemsets(j).suporte+(1/apriori.nroTransacoes);
					end
				end
			end
			%Checa quais itens são frequentes ou não. Elimina os
			%infrequentes.
			[itemsets,itemsetVazio] = apriori.checaSup(itemsets,apriori.minSup);
		end
		
		%{
		Função responsável por gerar as regras de associação a partir dos
		itensets frequentes determinados pelo Apriori. Somente as regras
		fortes (confianca >= minConf) são incluídas.
		Parâmetros
		itemsetsFrequentes: Struct contendo todos os k-itemsets frequentes
		gerados pelo Apriori.
		Saída
		regras: Struct contendo todas as regras de cada um dos k-itemsets
		%}
		function regras = geraRegras(apriori,itemsetsFrequentes,k)
			w=1;
			regras = struct('itemsetPai',[],'visualizacao',[],'suporte',[],'confianca',[]);
			fprintf("Gerando regras de assosiação\n");
			for i=2:k
				%fprintf("%.2f%%\n",i/k*100);
				itemsets = itemsetsFrequentes{i};
				for j=1:length(itemsets)
					for m=1:length(itemsets(j).itens)-1
						s = combnk(itemsets(j).itens,m);
						for n=1:size(s,1)
							%Gera A => (I-A)
							A = s(n,:);
							B = setdiff(itemsets(j).itens,A,'stable');
							%Acha o suporte de A no itemset anterior
							suporteA = apriori.achaSuporte(itemsetsFrequentes{length(A)},A);
							%Calcula a confiaça
							confianca = itemsets(j).suporte/suporteA;
							%Checa se a regra é forte
							if confianca >= apriori.minConf
								%Inclui a regra
								regras(w).confianca = confianca;
								%define o itemset de origem
								regras(w).itemsetPai = itemsets(j).itens;
								%define o suporte
								regras(w).suporte = itemsets(j).suporte;
								%Gera a visualização
								strA = sprintf('^%d',A);
								strA = strA(2:end);
								strB = sprintf('^%d',B);
								strB = strB(2:end);
								regras(w).visualizacao = [strA,' => ',strB];
								%Avança o contador
								w=w+1;
							end
						end
					end
				end
			end
			%Ordena as regras por suporte e confiança
			regras = apriori.sortRegras(regras);
			fprintf("Regras geradas\n");
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
		
		%{
		Função utilizada para determinar se o suporte de um item é menor do
		que minSup. Através disso determina quais são os itens frequentes,
		eliminando os que não são.
		Parâmetros
		itemsets: Itemset que será analisado
		minSup: Suporte mínimo desejado para considerar um item frequente.
		Saídas
		itemsets: Itemset frequente, itens não frequentes foram excluídos.
		itemsetVazio: Variável que checa se o conjunto ficou vazio após a
			exclusão. Usada na condição de parada.
		%}
		function [itemsets,itemsetVazio] = checaSup(itemsets,minSup)
			%Determina quais são frequentes
			i=1;
			while i <= length(itemsets)
				if itemsets(i).suporte < minSup
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
		
		%{
		Função que localiza o itemset A dentro do conjunto de itemsets e
		retorna seu suporte.
		Parâmetros
		itemsets: Conjunto de itemsets aonde A será buscado.
		A: Itemset cujo suporte deseja-se obter.
		Saída
		suporteA: Suporte do itemset A.
		%}
		function suporteA = achaSuporte(itemsets,A)
			suporteA=0;
			for i=1:length(itemsets)
				if isequal(itemsets(i).itens,A)
					suporteA = itemsets(i).suporte;
				end
			end
		end
		
		%{
		Função para ordernar as regras de forma decrescente com base no
		suporte e confiança
		Parâmetros
		regras: regras de associação a serem ordenadas
		Saída
		regrasOrd: regras após ordenação
		%}
		function regrasOrd = sortRegras(regras)
			fieldsR = fieldnames(regras);
			cellR = struct2cell(regras);
			sz = size(cellR);
			cellR = reshape(cellR, sz(1),[]);
			cellR = cellR';
			cellR = sortrows(cellR,[3 4],'descend');
			cellR = reshape(cellR', sz);
			regrasOrd = cell2struct(cellR, fieldsR, 1);
		end
	end
end