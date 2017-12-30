%{
Objeto responsável por representar um um algoritmo genetico.
Atributos
funcao: Objeto do tipo funcao. Contem o cálculo da saída da funcão que será
otimizada.
representacao: Indica qual representação será utilizada no GA, binária ou
real.
selecao: Struct com os campos:
	tipo: Indica qual seleção será utilizada no GA. Roleta, torneio ou
	elitista.
	pares: Pares de indivíduos selecionados para o crossover.
pMutacao: porcentagem de mutação do GA.
pCrossover: porcetagem de crossover do GA.
populacao: Struct com os campos:
	intervaloVariaveis: Inicio e fim de cada variável na representação
	binária.
	tamanho: Tamanho da população
	matriz: Matriz que representa os indivíduos
	melhor: Melhor indivíduo da população
fenotipo: Struct com os campos:
	matriz: Matriz que representa o fenótipo dos indivíduos.
	melhor: Fenótipo do melhor indivíduo.
fitness: Struct com os campos:
	matriz: Matriz de fitness dos indivíduos.
	melhor: Melhor fitness da população.
	medio: Fitness médio da população.
	gráfico: Gráfico do comportamento do fitness ao longo do GA.
%}
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
		%{
		Construtor
		Atributos
		nomeFuncao: nome da função para qual o GA será executado.
		intervaloBusca: Intervalo de busca para o qual a função será
		otimizada.
		precisao: Precisão desejada na otimização. É utilizada para
		determinar o tamanho da representação binária.
		representacao: Representação que será utilizada no GA, real ou
		binária.
		nomeSelecao: Nome do tipo de seleção que será utilizada no GA.
		pMutacao: Porcentagem de mutação que será utilizada no GA.
		pCrossover: Porcentagem de crossover que será utilizado no GA.
		Saída
		genetico: Algoritmo genético inicializado
		%}
		function genetico = Genetico(nomeFuncao,intervaloBusca,precisao,representacao,nomeSelecao,pMutacao,pCrossover)
			genetico.funcao = Funcao(nomeFuncao,intervaloBusca,precisao);
			genetico.representacao = representacao;
			genetico.selecao.tipo = nomeSelecao;
			genetico.pMutacao = pMutacao;
			genetico.pCrossover = pCrossover;
		end
		
		%Executa toda a rotina do GA
		%Somente clássico no momento
		function executa(genetico,geracoesMax,tamanhoPopulacao)
			geracoes = 1;
			melhorFitness = zeros(geracoesMax,1);
			mediaFitness = zeros(geracoesMax,1);
			inicializaPopulacao(genetico,tamanhoPopulacao);
			geraFenotipo(genetico);
			calcFitness(genetico);
			melhorFitness(geracoes) = genetico.fitness.melhor;
			mediaFitness(geracoes) = genetico.fitness.medio;
			fprintf("geração: %d fitnessMelhor: %2.4f fitnessMedio: %2.4f\n",geracoes,genetico.fitness.melhor,genetico.fitness.medio);
			while geracoes < geracoesMax
				seleciona(genetico);
				novaPopulacao = crossover(genetico,genetico.populacao.tamanho);
				novaPopulacao = mutacao(genetico,novaPopulacao);
				geracoes = geracoes+1;
				genetico.populacao.matriz = novaPopulacao;
				geraFenotipo(genetico);
				calcFitness(genetico);
				melhorFitness(geracoes) = genetico.fitness.melhor;
				mediaFitness(geracoes) = genetico.fitness.medio;
				fprintf("geração: %d fitnessMelhor: %2.4f fitnessMedio: %2.4f\n",geracoes,genetico.fitness.melhor,genetico.fitness.medio);
			end
			plotaFitness(genetico,melhorFitness,mediaFitness);
		end
		
		%Retorna uma populacão iniciada aleatoriamente
		%SOMENTE REPRESENTAÇÃO BINÁRIA NO MOMENTO
		function inicializaPopulacao(genetico,tamanhoPopulacao)
			if genetico.representacao == 'binária'
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
		end
		
		%Traduz a representação binária para real
		function geraFenotipo(genetico)
			for i=1:genetico.populacao.tamanho
				for j=1:size(genetico.populacao.intervaloVariaveis,1)
					genetico.fenotipo.matriz(i,j) = genetico.funcao.intervaloBusca(1)+...
						bi2de(genetico.populacao.matriz(i,genetico.populacao.intervaloVariaveis(j,1):...
						genetico.populacao.intervaloVariaveis(j,2)))*genetico.funcao.precisao;
				end
			end
		end
		
		%Cálcula o fitness e acha o melhor indivíduo
		function calcFitness(genetico)
			for i=1:genetico.populacao.tamanho
				genetico.fitness.matriz(i,1) = 1/(genetico.funcao.calcula(genetico.fenotipo.matriz(i,:))+1.0e-4);
				%Checa por descontinuidades
				if isnan(genetico.fitness.matriz(i,1))
					genetico.fitness.matriz(i,1)=-10000;
				end
			end
			[genetico.fitness.melhor,pos] = max(genetico.fitness.matriz);
			genetico.fitness.medio = mean(genetico.fitness.matriz);
			%Melhor indivíduo
			genetico.populacao.melhor = genetico.populacao.matriz(pos,:);
			genetico.fenotipo.melhor = genetico.fenotipo.matriz(pos,:);
		end
		
		%Realzia a etapa de seleção
		%Somente roleta no momento
		function seleciona(genetico)
			roleta(genetico);
		end
		
		%Crossover de um ponto
		function novaPopulacao = crossover(genetico,tamanhoNovaPopulacao)
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
					novaPopulacao(i,1:ponto) = genetico.populacao.matriz(genetico.selecao.pares(i,1),1:ponto);
					novaPopulacao(i,ponto+1:end) = genetico.populacao.matriz(genetico.selecao.pares(i,2),ponto+1:end);
					%Gera filho dois
					novaPopulacao(i+1,1:ponto) = genetico.populacao.matriz(genetico.selecao.pares(i,2),1:ponto);
					novaPopulacao(i+1,ponto+1:end) = genetico.populacao.matriz(genetico.selecao.pares(i,1),ponto+1:end);
				%Não faz crossover
				else
					%Filhos são iguais aos pais
					novaPopulacao(i,:)= genetico.populacao.matriz(genetico.selecao.pares(i,1),:);
					novaPopulacao(i+1,:)= genetico.populacao.matriz(genetico.selecao.pares(i,2),:);
				end
			end
		end
		
		%Mutação bit a bit
		function novaPopulacao = mutacao(genetico,populacaoInicial)
			novaPopulacao = populacaoInicial;
			for i=1:size(novaPopulacao,1)
				for j=1:size(novaPopulacao,2)
					r = rand;
					if r <= genetico.pMutacao
						novaPopulacao(i,j) = ~novaPopulacao(i,j);
					end
				end
			end
		end
	end
	
	%Métodos auxiliares chamados pelas funções principais
	methods (Access = private)
		%Ordena as matrizes de população, fenotipo e fitness de acordo com
		%o fitness
		function ordena(genetico)
			[genetico.fitness.matriz,ordem] = sort(genetico.fitness.matriz);
			genetico.fenotipo.matriz = genetico.fenotipo.matriz(ordem,:);
			genetico.populacao.matriz = genetico.populacao.matriz(ordem,:);
		end
		
		%Seleção via roleta
		%Fazer sortear um número específico de indivíduos
		function roleta(genetico)
			ordena(genetico);
			%Normaliza o fitness
			a=1;
			b=100;
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
		
		%Plota o comportamento do fitness melhor e médio
		function plotaFitness(genetico,melhorFitness,mediaFitness)
			figura = figure('Name',['Gráfico - ',genetico.funcao.nome],'NumberTitle','Off','Visible', 'off');
			plot(melhorFitness,'DisplayName','Melhor');
			hold on
			plot(mediaFitness,'DisplayName','Medio');
			hold off
			title("GA - Função "+genetico.funcao.nome);
			xlabel("Gerações");
			ylabel("Fitness");
			%legend('show','Location','best');
			genetico.fitness.grafico = figura;
		end
		
	end
end