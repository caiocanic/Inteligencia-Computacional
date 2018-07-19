%{
Classe responsável por representar o método Apriori
Atributos
transacoes: Struct que representa o conjunto de transacoes que serão
	analisadas pelo algorítmo. Possui os campos: id que correseponde ao
	itentificador da transacao e itens que lista os itens inclusos naquela
	transação.

Métodos

%}
classdef Apriori < handle
	properties (SetAccess = private)
		transacoes;
		
	end
	
	methods
		%{
		Método construtor
		%}
		function apriori = Apriori(transacoes)
			
		end
	end
	
	methods (Static = true, Access = private)
		%{
		Método para transformar as transações presentes no conjunto de
		dados no formato do atributo transacoes.
		%}
		function transacoes = extraiTransacoes(dados)
			n = size(dados,1); %número de transacoes
			
		end
	
	end
	
end