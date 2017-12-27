%%Fenotipo implementado%%
classdef Genetico < handle
	properties
		funcao
		representacao
		selecao
		pMutacao
		pCrossover
		populacao
		fenotipo
		fitness
		diversidade
	end
	methods
		%Construtor
		function genetico = Genetico(nomeFuncao,intervaloBusca,precisao,representacao,nomeSelecao,pMutacao,pCrossover)
			genetico.funcao = Funcao(nomeFuncao,intervaloBusca,precisao);
			genetico.representacao = representacao;
			genetico.selecao.tipo = nomeSelecao;
			genetico.pMutacao = pMutacao;
			genetico.pCrossover = pCrossover;
		end
		
		%Retorna uma populacão iniciada aleatoriamente
		function inicializaPopulacao(genetico,tamanhoPopulacao)
			syms n;
			nroBits = 0;
			for i=1:size(genetico.funcao.intervaloBusca,1)
				eqn=(genetico.funcao.intervaloBusca(i,2)-genetico.funcao.intervaloBusca(i,1))/((2^n)-1)...
				== 2*genetico.funcao.precisao;
				genetico.populacao.intervaloVariaveis(i,1) = nroBits+1;
				nroBits = nroBits + ceil(double(vpasolve(eqn,n)));
				genetico.populacao.intervaloVariaveis(i,2) = nroBits;
			end
			genetico.populacao.tamanho = tamanhoPopulacao;
			genetico.populacao.matriz = round(rand(tamanhoPopulacao,nroBits));
		end
		
		%Traduz a representação binária para real
		function geraFenotipo(genetico)
			for i=1:genetico.populacao.tamanho
				for j=1:size(genetico.populacao.intervaloVariaveis,1)
					genetico.fenotipo(i,j) = genetico.funcao.intervaloBusca(1)+...
					bi2de(genetico.populacao.matriz(i,genetico.populacao.intervaloVariaveis(j,1):...
					genetico.populacao.intervaloVariaveis(j,2)))*genetico.funcao.precisao;
				end
			end
		end
		
		%Cálcula o fitness
		function calcFitness(genetico)
			for i=1:genetico.populacao.tamanho
				genetico.fitness.matriz(i,1) = -genetico.funcao.calcula(genetico.fenotipo(i,:));
			end
			genetico.fitness.melhor = max(genetico.fitness.matriz);
			genetico.fitness.medio = mean(genetico.fitness.matriz);
		end
		
		%Realzia a etapa de seleção
		function seleciona(genetico)
			roleta(genetico);
		end
		
		%Crossover de um ponto
		function crossover(genetico)
			%Sorteia um ponto
			
		end
		
		%Mutação bit a bit
		function mutacao()
			
		end
	end
	methods (Access = private)
		%Ordena as matrizes de população, fenotipo e fitness de acordo com
		%o fitness
		function ordena(genetico)
			[genetico.fitness.matriz,ordem] = sort(genetico.fitness.matriz);
			genetico.fenotipo = genetico.fenotipo(ordem,:);
			genetico.populacao.matriz = genetico.populacao.matriz(ordem,:);
		end
		
		%Seleção via roleta
		function roleta(genetico)
			ordena(genetico);
			%Normaliza o fitness
			a=1;
			b=25;
			fitnessNorm =a+((genetico.fitness.matriz-min(genetico.fitness.matriz))*(b-a))/(max((genetico.fitness.matriz))-min(genetico.fitness.matriz));
			%Gera os intervalos da roleta.
			porcentagensRoleta = fitnessNorm/sum(fitnessNorm);
			intervalosRoleta = zeros(genetico.populacao.tamanho,2);
			intervalosRoleta(1,1) = 0;
			intervalosRoleta(1,2) = porcentagensRoleta(1);
			for i=1:genetico.populacao.tamanho-1
				intervalosRoleta(i+1,1) = sum(porcentagensRoleta(1:i));
				intervalosRoleta(i+1,2) = sum(porcentagensRoleta(1:i+1));
			end
			%Sorteia os pares de indivíduos para crossover
			for i=1:genetico.populacao.tamanho
				r1 = rand;
				r2 = rand;
				%Sorteia primeiro indivíduo
				for j=1:genetico.populacao.tamanho
					if r1 >= intervalosRoleta(j,1) && r1 < intervalosRoleta(j,2)
						genetico.selecao.pares(i,1) = j;
						break;
					end
				end
				%Sorteia segundo indivíduo
				for j=1:genetico.populacao.tamanho
					if r2 >= intervalosRoleta(j,1) && r2 < intervalosRoleta(j,2)
						genetico.selecao.pares(i,2) = j;
						break;
					end
				end
			end
		end
	end
end