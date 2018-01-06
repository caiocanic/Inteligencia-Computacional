classdef Crossover
	methods (Static = true)
		%Crossover de um ponto
		function novaPopulacao = umPonto(genetico,selecionados)
			intervalo = [1,size(genetico.populacao.matriz,2)];
			novaPopulacao = zeros(length(selecionados)/2,intervalo(2));
			for i=1:2:length(selecionados)/2
				%Checa se ocorrerá crossover
				r = rand;
				%Faz crossover
				if r <= genetico.pCrossover
					%Sorteia um ponto
					ponto = round(intervalo(1) + (intervalo(2)-intervalo(1)).*rand);
					%Gera filho um
					novaPopulacao(i,1:ponto) = genetico.populacao.matriz(selecionados(i),1:ponto);
					novaPopulacao(i,ponto+1:end) = genetico.populacao.matriz(selecionados(i+1),ponto+1:end);
					%Gera filho dois
					novaPopulacao(i+1,1:ponto) = genetico.populacao.matriz(selecionados(i+1),1:ponto);
					novaPopulacao(i+1,ponto+1:end) = genetico.populacao.matriz(selecionados(i),ponto+1:end);
				%Não faz crossover
				else
					%Filhos são iguais aos pais
					novaPopulacao(i,:)= genetico.populacao.matriz(selecionados(i),:);
					novaPopulacao(i+1,:)= genetico.populacao.matriz(selecionados(i+1),:);
				end
			end
		end
		
		%Crossover dois pontos
		function novaPopulacao = doisPontos(genetico,selecionados)
			%Garante pelo intervalo que o ponto não esteja nas pontas
			intervalo = [2,size(genetico.populacao.matriz,2)-1];
			novaPopulacao = zeros(genetico.populacao.tamanho,genetico.populacao.nroBits);
			for i=1:2:length(selecionados)/2
				%Checa se ocorrerá crossover
				r = rand;
				%Faz crossover
				if r <= genetico.pCrossover
					%Sorteia dois pontos
					p1 = round(intervalo(1) + (intervalo(2)-intervalo(1)).*rand);
					p2 = round(intervalo(1) + (intervalo(2)-intervalo(1)).*rand);
					%Garante que eles não sejam iguais
					while p1==p2
						p1 = round(intervalo(1) + (intervalo(2)-intervalo(1)).*rand);
						p2 = round(intervalo(1) + (intervalo(2)-intervalo(1)).*rand);
					end
					%Garante que p1 seja o mair
					if p2>p1
						temp = p1;
						p1 = p2;
						p2 = temp;
					end
					%Gera filho um
					novaPopulacao(i,1:p1-1) = genetico.populacao.matriz(selecionados(i),1:p1-1);
					novaPopulacao(i,p1:p2) = genetico.populacao.matriz(selecionados(i+1),p1:p2);
					novaPopulacao(i,p2+1:end) = genetico.populacao.matriz(selecionados(i),p2+1:end);
					%Gera filho dois
					novaPopulacao(i+1,1:p1-1) = genetico.populacao.matriz(selecionados(i+1),1:p1-1);
					novaPopulacao(i+1,p1:p2) = genetico.populacao.matriz(selecionados(i),p1:p2);
					novaPopulacao(i+1,p2+1:end) = genetico.populacao.matriz(selecionados(i+1),p2+1:end);
				else
					%Filhos são iguais aos pais
					novaPopulacao(i,:)= genetico.populacao.matriz(selecionados(i),:);
					novaPopulacao(i+1,:)= genetico.populacao.matriz(selecionados(i+1),:);
				end
			end
		end
		%Crossover uniforme
		function novaPopulacao = uniforme(genetico,selecionados)
			novaPopulacao = zeros(length(selecionados)/2,genetico.populacao.nroBits);
			for i=1:2:length(selecionados)/2
				%Checa se ocorrerá crossover
				r = rand;
				%Faz crossover
				if r <= genetico.pCrossover
					%Gera a máscara
					mascara = round(rand(1,genetico.populacao.nroBits));
					for j=1:genetico.populacao.nroBits
						if mascara(j) == 0
							novaPopulacao(i,j) = genetico.populacao.matriz(selecionados(i),j);
							novaPopulacao(i+1,j) = genetico.populacao.matriz(selecionados(i+1),j);
						else
							novaPopulacao(i,j) = genetico.populacao.matriz(selecionados(i+1),j);
							novaPopulacao(i+1,j) = genetico.populacao.matriz(selecionados(i),j);
						end
					end
				%Não faz crossover
				else
					novaPopulacao(i,:) = genetico.populacao.matriz(selecionados(i),:);
					novaPopulacao(i+1,:) = genetico.populacao.matriz(selecionados(i+1),:);
				end
			end
		end
	end
end