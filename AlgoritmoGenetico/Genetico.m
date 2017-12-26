%%Fenotipo implementado%%
classdef Genetico < handle
	properties
		funcao
		representacao
		pMutacao
		pCrossover
		populacao
		fenotipo
		fitness
		fitnessMelhor
		fitnessMedio
		diversidade
		selecao
	end
	methods
		%Construtor
		function genetico = Genetico(nomeFuncao,intervaloBusca,precisao,representacao,pMutacao,pCrossover)
			genetico.funcao = Funcao(nomeFuncao,intervaloBusca,precisao);
			genetico.representacao = representacao;
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
				genetico.populacao.intervaloVariavel(i,1) = nroBits+1;
				nroBits = nroBits + ceil(double(vpasolve(eqn,n)));
				genetico.populacao.intervaloVariavel(i,2) = nroBits;
			end
			genetico.populacao.tamanho = tamanhoPopulacao;
			genetico.populacao.matriz = round(rand(tamanhoPopulacao,nroBits));
		end
		
		%Traduz a representação binária para real
		function geraFenotipo(genetico)
			for i=1:genetico.populacao.tamanho
				for j=1:size(genetico.populacao.intervaloVariavel,1)
					genetico.fenotipo(i,j) = genetico.funcao.intervaloBusca(1)+...
					bi2de(genetico.populacao.matriz(i,genetico.populacao.intervaloVariavel(j,1):...
					genetico.populacao.intervaloVariavel(j,2)))*genetico.funcao.precisao;
				end
			end
		end
		
		function calcFitness(genetico)
			genetico.fitness.matriz = calcFunc(genetico.populacao.matriz);
		end
		
		%Crossover de um ponto
		function crossover(genetico)
			%Sorteia um ponto
			
		end
		
		%Mutação bit a bit
		function mutacao()
			
		end
	end
end