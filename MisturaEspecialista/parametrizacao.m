%{
Fluxo princpal de execução da parâmetrização e teste da mistura de
especialistas.
Parâmetros Internos
kMax: Número de partições geradas no k-fold.
lagMax: Número máximo de lags que serão analisados em busca do ideal para a
	entrada
porcValidacao: Porcentagem do conjunto de treinamento que será dedicada a
	validação.
nVlMax: Número máximo permitido de validações consecutivas em que não
	ocorre melhora do desempenho durante o treinamento.
func: Funções de ativação que serão testadas.
hMax: Número máximo de neurônios que será testado nas mlps.
nroTestes: Número de vezes que o k-fold crossvalidation é executado.
mMax: Número máximo de especialistas que serão testados na mistura.
nepMax: Número de épocas de treinamento da mistura.
%}
function [he,funcE,misturaBest] = parametrizacao()
	%Parâmetros Internos
	kMax = 10;
	lagMax = 35;
	porcValidacao = 0.3;
	nVlMax = 25;
	func = ["tangente","linear";
			"sigmoid","tangente";
			"tangente","tangente"];
	hMax = 37;
	nroTestes = 12;
	mMax = 6;
	nepMax = 100;
	
	%Carrega os dados
	dados = load("treinamento.txt");
	%Analisa parâmetros da MLP
	if exist(['resultados',filesep,'eqmMlpFinal.mat'],'file') == 0
		eqmMlpTemp = cell(1,nroTestes);
		desvioMlpTemp = cell(1,nroTestes);
		%Usar parfor se disponível
		for i=1:nroTestes
			%Gera o particionamento
			kfold = ProcessaDados.geraKFolds(dados,kMax);
			%Analisa o desempenho para esse particionamento
			[eqmMlpTemp{i},desvioMlpTemp{i}] = analisaMlp(kfold,kMax,lagMax,porcValidacao,nVlMax,func,hMax,i);
		end
		%Faz a média dos resultados
		eqmMlpFinal = zeros(size(func,1),hMax-1);
		desvioMlpFinal = zeros(size(func,1),hMax-1);
		for i=1:nroTestes
			eqmMlpFinal = eqmMlpFinal+eqmMlpTemp{i};
			desvioMlpFinal = desvioMlpFinal+desvioMlpTemp{i};
		end
		eqmMlpFinal = eqmMlpFinal/nroTestes;
		desvioMlpFinal = desvioMlpFinal/nroTestes;
		%Salva os resultados
		save('eqmMlpFinal','eqmMlpFinal');
		save('desvioMlpFinal','desvioMlpFinal');
	else
		eqmMlpFinal = cell2mat(struct2cell(load(['resultados',filesep,'eqmMlpFinal.mat'])));
		desvioMlpFinal = cell2mat(struct2cell(load(['resultados',filesep,'desvioMlpFinal.mat'])));
	end
	
	%Determina as melhores configurações da MLP para serem os
	%especialistas.
	eqmTemp = eqmMlpFinal;
	he = zeros(1,mMax);
	funcE = strings(mMax,2); 
	for i=1:mMax
		minimo = min(min(eqmTemp));
		[row,col] = find(eqmTemp==minimo);
		he(i) = col+1;
		funcE(i,1) = func(row,1);
		funcE(i,2) = func(row,2);
		eqmTemp(row,col) = 1;
	end

	%Analisa a mistura
	if exist(['resultados',filesep,'eqmMlpFinal.mat'],'file') == 0
		%Analisa as configurações possíveis para a mistura
		eqmMisturaTemp = cell(1,nroTestes/2);
		desvioMisturaTemp = cell(1,nroTestes/2);
		for i=1:nroTestes/2
			kfold = ProcessaDados.geraKFolds(dados,kMax);
			[eqmMisturaTemp{i},desvioMisturaTemp{i}] = analisaMistura(kfold,kMax,lagMax,porcValidacao,nVlMax,mMax,he,funcE,nepMax,testeAtual);
		end
		%Tira a média dos resultados
		eqmMisturaFinal = zeros(1,mMax);
		desvioMisturaFinal = zeros(1,mMax);
		%Usar parfor se disponível
		for j=1:nroTestes/2
			eqmMisturaFinal = eqmMisturaFinal+eqmMisturaTemp{i};
			desvioMisturaFinal = desvioMisturaFinal+desvioMisturaTemp{i};
		end
		eqmMisturaFinal = eqmMisturaFinal/(nroTestes/2);
		desvioMisturaFinal = desvioMisturaFinal/(nroTestes/2);
		%Salva os resultados
		save('eqmMisturaFinal','eqmMisturaFinal');
		save('desvioMisturaFinal','desvioMisturaFinal');
	else
		eqmMisturaFinal = cell2mat(struct2cell(load(['resultados',filesep,'eqmMisturaFinal.mat'])));
		desvioMisturaFinal = cell2mat(struct2cell(load(['resultados',filesep,'desvioMisturaFinal.mat'])));
	end
	
	%Treina a melhor rede com o conjunto inteiro de treinamento.
	%Realiza pré-processamento
	treinamento = dados;
	%Determina o melhor m
	[~,pos] = min(eqmMisturaFinal);
	m = pos+1;
	%Acha a configuração dos especialistas
	h = he(1:m);
	func = funcE(1:m,:);
	%Processa os dados de treinamento
	lag = ProcessaDados.achaLag(treinamento,lagMax);
	[Xtr,Ydtr,Xvl,Ydvl,~,~] = ProcessaDados.processaTreinamento(treinamento,lag,porcValidacao);
	%Treina a rede.
	misturaBest = Mistura(m);
	misturaBest.treinamento(Xtr,Ydtr,Xvl,Ydvl,nVlMax,h,func,nepMax);
	save('misturaBest','misturaBest');
end

%Analisa os parâmetros da MLP. Encontra as melhoras configurações de MLPs para serem utilizados como
%especialistas.
function [eqmMlp,desvioMlp] = analisaMlp(kfold,kMax,lagMax,porcValidacao,nVlMax,func,hMax,testeAtual)
	eqmMlp = zeros(size(func,1),hMax-1);
	desvioMlp = zeros(size(func,1),hMax-1);
	%Analisa as funções de ativação
	for	i=1:size(func,1)
		funcA=func(i,1);
		funcB=func(i,2);
		fprintf("%s %s\n",funcA,funcB);
		%Analisa o número de neurônios
		for h=2:hMax
			fprintf("%d\n",h);
			EQMtemp = zeros(10,kMax);
			%Executa o k-fold crossvalidation
			for kAtual=1:kMax
				teste = kfold{kAtual};
				treinamento = [];
				for w=1:kMax
					if w ~= kAtual
						treinamento = cat(1,treinamento,kfold{kAtual});
					end
				end
				%Processa os dados
				lag = ProcessaDados.achaLag(treinamento,lagMax);
				[Xtr,Ydtr,Xvl,Ydvl,media,desvio] = ProcessaDados.processaTreinamento(treinamento,lag,porcValidacao);
				Xts = ProcessaDados.processaTeste(treinamento,teste,lag,media,desvio);
				%Treina e testa 10x cada fold para considerar aleatoriedade
				%dos pesos
				for j=1:10
					mlp = Mlp(funcA,funcB,h,10000,0.1);
					mlp.treinamento(Xtr,Ydtr,Xvl,Ydvl,nVlMax,ones(size(Ydtr)));
					mlp.teste(Xts);
					erro = mlp.Y(1:end-1,1) - teste(2:end,1);
					EQMtemp(j,kAtual) = EQMtemp(j,kAtual) + (1/size(Xts,1)*sum(sum(erro.*erro)));
				end
			end
			%Tira a média do k-fold crossvalidation
			eqmMlp(i,h-1) = sum(sum(EQMtemp))/(kMax*10);
			desvioMlp(i,h-1) = std2(EQMtemp);
		end
	end
	save(['eqmMlp',num2str(testeAtual)],'eqmMlp');
	save(['desvioMlp',num2str(testeAtual)],'desvioMlp');
end

%Determina a melhor configuração para a mistura de especialistas
function [eqmMistura,desvioMistura] = analisaMistura(kfold,kMax,lagMax,porcValidacao,nVlMax,mMax,he,funcE,nepMax,testeAtual)
	eqmMistura = zeros(1,mMax-1);
	desvioMistura = zeros(1,mMax-1);
	%Testa a quantidade de especialistas
	for m=2:mMax
		fprintf("m: %d\n",m);
		%Realiza o k-fold crossvalidation
		EQMtemp = zeros(5,kMax);
		h = he(1:m);
		func = funcE(1:m,:);
		for kAtual=1:kMax
			fprintf("k: %d\n",kAtual);
			teste = kfold{kAtual};
			treinamento = [];
			for w=1:kMax
				if w ~= kAtual
					treinamento = cat(1,treinamento,kfold{kAtual});
				end
			end
			%Processa os dados
			lag = ProcessaDados.achaLag(treinamento,lagMax);
			[Xtr,Ydtr,Xvl,Ydvl,media,desvio] = ProcessaDados.processaTreinamento(treinamento,lag,porcValidacao);
			Xts = ProcessaDados.processaTeste(treinamento,teste,lag,media,desvio);
			%Treina e testa 5x cada fold para considerar aleatoriedade
			%dos pesos
			for j=1:5
				mistura = Mistura(m);
				mistura.treinamento(Xtr,Ydtr,Xvl,Ydvl,nVlMax,h,func,nepMax);
				mistura.teste(Xts);
				erro = mistura.Ym(1:end-1,1) - teste(2:end,1);
				EQMtemp(j,kAtual) = EQMtemp(j,kAtual) + (1/size(Xts,1)*sum(sum(erro.*erro)));
			end
		end
		%Tira a média do k-fold crossvalidation
		eqmMistura(1,m-1) = sum(sum(EQMtemp))/(kMax*10);
		desvioMistura(1,m-1) = std2(EQMtemp);
	end
	save(['eqmMistura',num2str(testeAtual)],'eqmMistura');
	save(['desvioMistura',num2str(testeAtual)],'desvioMistura');
end