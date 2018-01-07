%{
Objeto responsável por representar um um algoritmo genetico.
Atributos
tipo: Tipo de GA. Clássico ou modificado.
precisao: Precisão que será utilizada na representação binária.
tipoSelecao: Indica qual seleção será utilizada no GA. Roleta, torneio ou
classista.
operacoes: Indica quais operações de recombinação serão executadas no GA
modificado.
pMutacao: porcentagem de mutação do GA.
pCrossover: porcetagem de crossover do GA.
parametrosRede: Struct com os parametros para inicialização da MLP dentro
do GA. Campos:
	h: Número de neurônios.
	ne: Número de entradas.
	ns: Número de saídas.
populacao: Struct com os campos:
	tamanho: Tamanho da população.
	matriz: Matriz que representa os indivíduos.
	nroBits: Número de bits para cada indivíduo.
	tamanhoVariavel: quantidade de bits usado por uma variável
	representada na população.
	melhor: Melhor indivíduo da população.
fenotipo: Struct com os campos:
	matriz: Matriz de redes mlp.
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
		precisao
		tipoSelecao
		operacoes
		pMutacao
		pCrossover
		parametrosRede
		populacao
		fenotipo
		fitness
	end
	
	methods
		%{
		Método construtor do objeto Genetico.
		Atributos
		tipo: Tipo de GA. Clássico ou modificado.
		precisao: Precisão desejada na otimização. É utilizada para
		determinar o tamanho da representação binária.
		nomeSelecao: Nome do tipo de seleção que será utilizada no GA.
		operacoes: Operações que serão realizadas no GA modificado. O GA
		clássico tem operações pre-determinadas.
		pMutacao: Porcentagem de mutação que será utilizada no GA.
		pCrossover: Porcentagem de crossover que será utilizado no GA.
		parametrosRede: Struct com os parametros para inicialização da MLP
		dentro do GA. Campos:
			h: Número de neurônios.
			ne: Número de entradas.
			ns: Número de saídas.
		Saída
		genetico: Algoritmo genético inicializado.
		%}
		function genetico = Genetico(tipo,precisao,nomeSelecao,operacoes,pMutacao,pCrossover,parametrosRede)
			genetico.tipo = tipo;
			genetico.precisao = precisao;
			genetico.tipoSelecao = nomeSelecao;
			genetico.operacoes = operacoes;
			genetico.pMutacao = pMutacao;
			genetico.pCrossover = pCrossover;
			genetico.parametrosRede = parametrosRede;
		end
		
		%{
		Método responsável por executar toda a rotina do GA tanto para o
		clássico como para o modificado. Inicializa a população, gera o
		fenotipo, calculá o fitness e realiza a seleção. Repete por
		<geracoesMax>. Essa função também salva o comportamento do fitness
		médio e máximo ao longo das gerações.
		Atributos
		genetico: Objeto do tipo Genetico já inicializado.
		geracoesMax: Número máximo de gerações que serão geradas no GA.
		tamanhoPopulacao: Tamanho da população que será criada com o GA.
		Xtr: Conjunto de treinamento para as redes MLP.
		Ydtr: Saída desejada para Xtr.
		%}
		function executa(genetico,geracoesMax,tamanhoPopulacao,Xtr,Ydtr)
			geracoes = 1;
			melhorFitness = zeros(geracoesMax,1);
			mediaFitness = zeros(geracoesMax,1);
			inicializaPopulacao(genetico,tamanhoPopulacao);
			geraFenotipo(genetico);
			calcFitness(genetico,Xtr,Ydtr);
			melhorFitness(geracoes) = genetico.fitness.melhor;
			mediaFitness(geracoes) = genetico.fitness.medio;
			fprintf("geração: %d fitnessMelhor: %2.4f fitnessMedio: %2.4f\n",geracoes,genetico.fitness.melhor,genetico.fitness.medio);
			if genetico.tipo == "classico"
				while geracoes < geracoesMax
					selecionados = seleciona(genetico,genetico.populacao.tamanho*2);
					novaPopulacao = Crossover.umPonto(genetico,selecionados);
					novaPopulacao = Mutacao.pontual(genetico,novaPopulacao);
					geracoes = geracoes+1;
					genetico.populacao.matriz = novaPopulacao;
					geraFenotipo(genetico);
					calcFitness(genetico,Xtr,Ydtr);
					melhorFitness(geracoes) = genetico.fitness.melhor;
					mediaFitness(geracoes) = genetico.fitness.medio;
					fprintf("geração: %d fitnessMelhor: %2.4f fitnessMedio: %2.4f\n",geracoes,genetico.fitness.melhor,genetico.fitness.medio);
				end
			elseif genetico.tipo == "modificado"
				%Define o tamanho max e min das subpopulações
				tamanhoMinSub = floor(genetico.populacao.tamanho*0.3);
				tamanhoMaxSub = ceil(genetico.populacao.tamanho*0.5);
				while geracoes < geracoesMax
					%Realiza as operações definidas
					populacaoIntermediaria = double.empty;
					for i=1:length(genetico.operacoes)
						%Sorteia um tamanho
						tamanhoSubPopulacao = round(tamanhoMinSub + (tamanhoMaxSub-tamanhoMinSub).*rand);
						%Garente que seja par para o crossover
						if mod(tamanhoSubPopulacao,2) == 1
							tamanhoSubPopulacao = tamanhoSubPopulacao+1;
						end
						subPopulacao = realizaOperacao(genetico,strsplit(genetico.operacoes(i)," "),tamanhoSubPopulacao);
						populacaoIntermediaria = [populacaoIntermediaria;subPopulacao];
					end
					%Avalia população intermediária
					tamanhoOld = genetico.populacao.tamanho;
					genetico.populacao.matriz = populacaoIntermediaria;
					genetico.populacao.tamanho = size(populacaoIntermediaria,1);
					geraFenotipo(genetico);
					calcFitness(genetico,Xtr,Ydtr);
					%Seleciona população intermediária
					selecionados = seleciona(genetico,tamanhoOld);
					novaPopulacao = zeros(length(selecionados),genetico.populacao.nroBits);
					for i=1:length(selecionados)
						novaPopulacao(i,:) = genetico.populacao.matriz(selecionados(i),:);
					end
					%Avalia a nova população
					genetico.populacao.tamanho = tamanhoOld;
					genetico.populacao.matriz = novaPopulacao;
					geraFenotipo(genetico);
					calcFitness(genetico,Xtr,Ydtr);
					geracoes = geracoes +1;
					melhorFitness(geracoes) = genetico.fitness.melhor;
					mediaFitness(geracoes) = genetico.fitness.medio;
					fprintf("geração: %d fitnessMelhor: %2.4f fitnessMedio: %2.4f\n",geracoes,genetico.fitness.melhor,genetico.fitness.medio);
				end
			else
				error('Tipo inválido');
			end
			plotaFitness(genetico,melhorFitness,mediaFitness);
		end
		
		%{
		Método responsável por inicializa a população do GA que representa
		os pesos das redes MLP que serão treinadas. Utiliza somente
		representação binária.
		Atributos
		genetico: Objeto do tipo genético já inicializado.
		tamanhoPopulacao: Tamanho desejado para a popuļação que será
		gerada.
		%}
		function inicializaPopulacao(genetico,tamanhoPopulacao)
			genetico.populacao.tamanho = tamanhoPopulacao;
			syms n;
			eqn=(2)/((2^n)-1)== 2*genetico.precisao;
			sol = ceil(double(vpasolve(eqn,n)));
			%Calcula número de bits para A
			nroBits = genetico.parametrosRede.h*(genetico.parametrosRede.ne+1)*sol; 
			%Calcula o número de bits para B
			nroBits = nroBits+(genetico.parametrosRede.ns*(genetico.parametrosRede.h+1)*sol);
			%Inicializa a população
			genetico.populacao.matriz = round(rand(tamanhoPopulacao,nroBits));
			genetico.populacao.nroBits = nroBits;
			genetico.populacao.tamanhoVariavel = sol;
		end
		
		%{
		Método responsável por traduzir a representação binária das matrizes A e B da MLP para
		representação real. Além disso é esse método que inicializa as
		redes.
		%}
		function geraFenotipo(genetico)
			genetico.fenotipo.matriz = Mlp.empty;
			for k=1:genetico.populacao.tamanho
				inicioVar=1;
				fimVar=genetico.populacao.tamanhoVariavel;
				%Traduz matriz A
				A = zeros(genetico.parametrosRede.h,genetico.parametrosRede.ne+1);
				for i=1:genetico.parametrosRede.h
					for j=1:genetico.parametrosRede.ne+1
						A(i,j)= -1+bi2de(genetico.populacao.matriz(k,inicioVar:fimVar))*genetico.precisao;
						inicioVar = fimVar+1;
						fimVar = fimVar+genetico.populacao.tamanhoVariavel;
					end
				end
				%Traduz matriz B
				B = zeros(genetico.parametrosRede.ns,genetico.parametrosRede.h+1);
				for i=1:genetico.parametrosRede.ns
					for j=1:genetico.parametrosRede.h+1
						B(i,j) = -1+bi2de(genetico.populacao.matriz(k,inicioVar:fimVar))*genetico.precisao;
						inicioVar = fimVar+1;
						fimVar = fimVar+genetico.populacao.tamanhoVariavel;
					end
				end
				genetico.fenotipo.matriz(k) = Mlp(genetico.parametrosRede.h,A,B);
			end
		end
		
		%Cálcula o fitness e acha o melhor indivíduo
		function calcFitness(genetico,Xtr,Ydtr)
			genetico.fitness.matriz = zeros(genetico.populacao.tamanho,1);
			for k=1:genetico.populacao.tamanho
				genetico.fenotipo.matriz(k).calcSaida(Xtr,Ydtr);
				genetico.fitness.matriz(k,1) = 1/genetico.fenotipo.matriz(k).EQM;
			end
			[genetico.fitness.melhor,pos] = max(genetico.fitness.matriz);
			genetico.fitness.medio = mean(genetico.fitness.matriz);
			%Melhor indivíduo
			genetico.populacao.melhor = genetico.populacao.matriz(pos,:);
			genetico.fenotipo.melhor = genetico.fenotipo.matriz(pos);
		end
		
		%Realzia a etapa de seleção
		function selecionados = seleciona(genetico,nroSorteios)
			ordena(genetico);
			if genetico.tipoSelecao == "roleta"
				selecionados = Selecao.roleta(genetico,nroSorteios);
			elseif genetico.tipoSelecao == "classista"
				b = 0.25;
				w = 0.10;
				selecionados = Selecao.classista(genetico,nroSorteios,b,w);
			elseif genetico.tipoSelecao == "torneio"
				selecionados = Selecao.torneio(genetico,nroSorteios);
			else
				error('Seleção inválida');
			end
		end
	end
	
	%Métodos auxiliares chamados pelas funções principais
	methods (Access = private)
		%Ordena as matrizes de população, fenotipo e fitness de acordo com
		%o fitness
		function ordena(genetico)
			[genetico.fitness.matriz,ordem] = sort(genetico.fitness.matriz);
			genetico.fenotipo.matriz = genetico.fenotipo.matriz(ordem);
			genetico.populacao.matriz = genetico.populacao.matriz(ordem,:);
		end
		
		%Plota o comportamento do fitness melhor e médio
		function plotaFitness(genetico,melhorFitness,mediaFitness)
			if genetico.tipo == "classico"
				titulo = "Clássico";
			elseif genetico.tipo == "modificado"
				titulo = "Modificado";
			else
				error('Tipo inválido');
			end
			figura = figure('Name','Gráfico - MLP','NumberTitle','Off','Visible', 'off');
			plot(melhorFitness,'DisplayName','Melhor');
			hold on
			plot(mediaFitness,'DisplayName','Medio');
			hold off
			title("GA "+titulo+" - MLP");
			xlabel("Gerações");
			ylabel("Fitness");
			%legend('show','Location','best');
			genetico.fitness.grafico = figura;
		end
		
		%Realiza as operações selecionadas para o genetico modificao
		function novaPopulacao = realizaOperacao(genetico,operacoes,tamanhoSubPopulacao)
			novaPopulacao = "";
			for i=1:length(operacoes)
				switch operacoes(1)
					case "umPonto"
						selecionados = seleciona(genetico,tamanhoSubPopulacao*2);
						novaPopulacao = Crossover.umPonto(genetico,selecionados);
					case "uniforme"
						selecionados = seleciona(genetico,tamanhoSubPopulacao*2);
						novaPopulacao = Crossover.uniforme(genetico,selecionados);
					case "doisPontos"
						selecionados = seleciona(genetico,tamanhoSubPopulacao*2);
						novaPopulacao = Crossover.doisPontos(genetico,selecionados);
					case "pontual"
						selecionados = seleciona(genetico,tamanhoSubPopulacao);
						if novaPopulacao == ""
							%Gera subpopulação para mutar
							novaPopulacao = geraSubpopulacao(genetico,selecionados);
						end
						novaPopulacao = Mutacao.pontual(genetico,novaPopulacao);
					case "troca"
						selecionados = seleciona(genetico,tamanhoSubPopulacao);
						if novaPopulacao == ""
							%Gera subpopulação para mutar
							novaPopulacao = geraSubpopulacao(genetico,selecionados);
						end
						novaPopulacao = Mutacao.pontual(genetico,novaPopulacao);
					case "reversiva"
						selecionados = seleciona(genetico,tamanhoSubPopulacao);
						if novaPopulacao == ""
							%Gera subpopulação para mutar
							novaPopulacao = geraSubpopulacao(genetico,selecionados);
						end
						novaPopulacao = Mutacao.reversiva(genetico,novaPopulacao);	
					case "novos"
						novaPopulacao = round(rand(tamanhoSubPopulacao,genetico.populacao.nroBits));
					case "melhores"
						ordena(genetico);
						novaPopulacao = genetico.populacao.matriz(end-tamanhoSubPopulacao+1:end,:);
					case "aleatorios"
						novaPopulacao = zeros(tamanhoSubPopulacao,genetico.populacao.nroBits);
						a = 1;
						b = genetico.populacao.tamanho;
						for k=1:tamanhoSubPopulacao
							r = round(a + (b-a)*rand);
							novaPopulacao(k,:) = genetico.populacao.matriz(r,:);
						end
					otherwise
						error('Operação inválida');
				end
			end
		end
		
		function novaPopulacao = geraSubpopulacao(genetico,selecionados)
			novaPopulacao = zeros(length(selecionados),genetico.populacao.nroBits);
			for j=1:length(selecionados)
				novaPopulacao(j,:) = genetico.populacao.matriz(selecionados(j),:);
			end
		end
	end
end
