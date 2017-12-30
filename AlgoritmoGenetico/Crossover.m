classdef Crossover
	methods (Static = true)
		%Crossover de um ponto
		function novaPopulacao = umPonto(genetico,selecao,tamanhoNovaPopulacao)
			intervalo = [1,size(genetico.populacao.matriz,2)];
			novaPopulacao = zeros(tamanhoNovaPopulacao,intervalo(2));
			for i=1:2:tamanhoNovaPopulacao
				%Checa se ocorrerá crossover
				r = rand;
				%Faz crossover
				if r <= genetico.pCrossover
					%Sorteia um ponto
					ponto = round(intervalo(1) + (intervalo(2)-intervalo(1)).*rand);
					%Gera filho um
					novaPopulacao(i,1:ponto) = genetico.populacao.matriz(selecao(i),1:ponto);
					novaPopulacao(i,ponto+1:end) = genetico.populacao.matriz(selecao(i+1),ponto+1:end);
					%Gera filho dois
					novaPopulacao(i+1,1:ponto) = genetico.populacao.matriz(selecao(i+1),1:ponto);
					novaPopulacao(i+1,ponto+1:end) = genetico.populacao.matriz(selecao(i),ponto+1:end);
				%Não faz crossover
				else
					%Filhos são iguais aos pais
					novaPopulacao(i,:)= genetico.populacao.matriz(selecao(i),:);
					novaPopulacao(i+1,:)= genetico.populacao.matriz(selecao(i+1),:);
				end
			end
		end
		
		%Crossover uniforme
		function novaPopulacao = uniforme(genetico,selecao,tamanhoNovaPopulacao)
			novaPopulacao = zeros(tamanhoNovaPopulacao,intervalo(2));
			for i=1:2:tamanhoNovaPopulacao
				%Checa se ocorrerá crossover
				r = rand;
				%Faz crossover
				if r <= genetico.pCrossover
					%Gera a máscara
					mascara = round(rand(1,intervalo(2)));
					for j=1:intervalo(2)
						if mascara(j) == 0
							novaPopulacao(i,j) = genetico.populacao.matriz(selecao(i),j);
							novaPopulacao(i+1,j) = genetico.populacao.matriz(selecao(i+1),j);
						else
							novaPopulacao(i,j) = genetico.populacao.matriz(selecao(i+1),j);
							novaPopulacao(i+1,j) = genetico.populacao.matriz(selecao(i),j);
						end
					end
				%Não faz crossover
				else
					novaPopulacao(i,:) = genetico.populacao.matriz(selecao(i),:);
					novaPopulacao(i+1,:) = genetico.populacao.matriz(selecao(i+1),:);
				end
			end
		end
	end
end