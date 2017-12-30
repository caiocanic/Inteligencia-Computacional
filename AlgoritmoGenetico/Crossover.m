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
		
		%Crossover pela média
		function novaPopulacao = media(genetico,selecionados)
			novaPopulacao = zeros(length(selecionados)/2,genetico.populacao.nroBits);
			for i=1:2:length(selecionados)/2
				%Checa se ocorrerá crossover
				r = rand;
				%Faz crossover
				if r <= genetico.pCrossover
					novaPopulacao(i,:) = (genetico.populacao.matriz(selecionados(i),:)+genetico.populacao.matriz(selecionados(i+1),:))/2;
				%Não faz crossover
				else
					novaPopulacao(i,:)=genetico.populacao.matriz(selecionados(i),:);
				end
			end
		end
		
		%Crossover combinação
		function novaPopulacao = combinacao(genetico,selecionados)
			a=0;
			b=1;
			novaPopulacao = zeros(length(selecionados)/2,genetico.populacao.nroBits);
			for i=1:2:length(selecionados)/2
				%Checa se ocorrerá crossover
				r = rand;
				%Faz crossover
				if r <= genetico.pCrossover
					n = a + (b-a).*rand;
					novaPopulacao(1,:) = (n*genetico.populacao.matriz(selecionados(i),:))+((1-n)*genetico.populacao.matriz(selecionados(i+1),:));
				%Não faz crossover
				else
					novaPopulacao(i,:)=genetico.populacao.matriz(selecionados(i),:);
				end
			end
		end
	end
end