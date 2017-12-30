%{
Objeto responsável por representar um um algoritmo genetico.
Atributos
tipo: Tipo de GA. Clássico ou modificado
funcao: Objeto do tipo funcao. Contem o cálculo da saída da funcão que será
otimizada.
representacao: Indica qual representação será utilizada no GA, binária ou
real.
tipoSelecao: Indica qual seleção será utilizada no GA. Roleta, torneio ou
classista.
operacoes: Indica quais operações de recombinação serão executadas.
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
		tipo
		funcao
		representacao
		tipoSelecao
		operacoes
		pMutacao
		pCrossover
		populacao
		fenotipo
		fitness
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
		function genetico = Genetico(tipo,nomeFuncao,intervaloBusca,precisao,representacao,nomeSelecao,pMutacao,pCrossover)
			genetico.tipo = tipo;
			genetico.funcao = Funcao(nomeFuncao,intervaloBusca,precisao);
			genetico.representacao = representacao;
			genetico.tipoSelecao = nomeSelecao;
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
			if genetico.tipo == "classico"
				while geracoes < geracoesMax
					selecionados = seleciona(genetico,genetico.populacao.tamanho*2);
					novaPopulacao = Crossover.umPonto(genetico,selecionados,genetico.populacao.tamanho);
					novaPopulacao = Mutacao.pontual(genetico,novaPopulacao);
					geracoes = geracoes+1;
					genetico.populacao.matriz = novaPopulacao;
					geraFenotipo(genetico);
					calcFitness(genetico);
					melhorFitness(geracoes) = genetico.fitness.melhor;
					mediaFitness(geracoes) = genetico.fitness.medio;
					fprintf("geração: %d fitnessMelhor: %2.4f fitnessMedio: %2.4f\n",geracoes,genetico.fitness.melhor,genetico.fitness.medio);
				end
				plotaFitness(genetico,melhorFitness,mediaFitness);
			elseif genetico.tipo == "modificado"
				while geracoes < geracoesMax
					%for operacoes
					%populacaoIntermediária
					
				end
			else
				error("Tipo inválido");
			end
		end
		
		%Retorna uma populacão iniciada aleatoriamente
		function inicializaPopulacao(genetico,tamanhoPopulacao)
			genetico.populacao.tamanho = tamanhoPopulacao;
			if genetico.representacao == "binária"
				syms n;
				nroBits = 0;
				for i=1:size(genetico.funcao.intervaloBusca,1)
					eqn=(genetico.funcao.intervaloBusca(i,2)-genetico.funcao.intervaloBusca(i,1))/((2^n)-1)...
						== 2*genetico.funcao.precisao;
					genetico.populacao.intervaloVariaveis(i,1) = nroBits+1;
					nroBits = nroBits + ceil(double(vpasolve(eqn,n)));
					genetico.populacao.intervaloVariaveis(i,2) = nroBits;
				end
				genetico.populacao.matriz = round(rand(tamanhoPopulacao,nroBits));
			elseif genetico.representacao == "real"
				for i=1:genetico.populacao.tamanho
					for j=1:size(genetico.funcao.intervaloBusca,1)
						a = genetico.funcao.intervaloBuca(i,1);
						b = genetico.funcao.intervaloBusca(i,2);
						genetico.populacao.matriz(i,j) = a + (b-a).*rand;
					end
				end
			else
				error("Representação inválida");
			end
		end
		
		%Traduz a representação binária para real
		function geraFenotipo(genetico)
			if genetico.representacao == "binária"
				for i=1:genetico.populacao.tamanho
					for j=1:size(genetico.populacao.intervaloVariaveis,1)
						genetico.fenotipo.matriz(i,j) = genetico.funcao.intervaloBusca(1)+...
							bi2de(genetico.populacao.matriz(i,genetico.populacao.intervaloVariaveis(j,1):...
							genetico.populacao.intervaloVariaveis(j,2)))*genetico.funcao.precisao;
					end
				end
			elseif genetico.representacao == "real"
				genetico.fenotipo.matriz = genetico.populacao.matriz;
			else
				error("Representação inválida");
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
		function selecionados = seleciona(genetico,nroSorteios)
			ordena(genetico);
			if genetico.tipoSelecao == "roleta"
				selecionados = Selecao.roleta(genetico,nroSorteios);
			elseif genetico.tipoSeleca == "classista"
				b = 0.15;
				w = 0.10;
				selecionados = Selecao.classista(genetico,nroSorteios,b,w);
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