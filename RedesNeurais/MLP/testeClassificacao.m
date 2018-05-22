%{
Função responsável por chamar a rotina de testes da MLP ou realizar apenas
um treinamento e teste para os dados parâmetros
%}
function testeClassificacao()
	hMax=12;
	nepMax=25000;
	alfaInicial=0.1;
	lagMax = 15;
	nroTestes = 10;
	porcValidacao = 0.3;
	h=3;
	lag=15;
	
	treinamento = load("Classificação/iris_treinamento.txt");
	teste = load("Classificação/iris_teste.txt");
	[Xtr,Ydtr,Xvl,Ydvl,Xts,Ydts] = processaClassificacao(treinamento,teste,porcValidacao);
	mlp = Mlp("sigmoid","softmax",h,nepMax,alfaInicial);
	mlp.treinamento(Xtr,Ydtr,Xvl,Ydvl);
	mlp.teste(Xts);
	acerto = traduzClasse(mlp.Y,Ydts)
	
end

%{
Função responsável por testar a MLP com diferentes valores de h (número de
neurónios) e lag (número de entradas atrasadas) para cada uma das séries
temporías. Para cada conjunto de valores são realizados <nroTestes> testes, sendo
salvo em um arquivo a média dos EQM's e o desvio padrão desses testes.
Parâmetros
hMax: Número máximo de neurónios com o qual a rede será testada;
nepMax: Número máximo de épocas para o treinamento da rede que será
testada;
alfaInicial: valor do alfa inicial com o qual a rede será inicializada;
lagMax: Número máximo de entradas atrasadas para o qual a rede será
testada;
nroTestes: Número de testes que serão realizados para cada conjunto de
atributos da rede;
porcValidacao: Porcentagens de dados de treinamento que serão utilizados
para validação;
Saídas salvas em arquivos
EQMmedioSerie.mat: Média dos EQM's testes realizados para uma dada série
EQMdesvioSerie.mat: Desvio padrão dos EQM's dos testes realizados
%}
function testaParametros(hMax, nepMax, alfaInicial, lagMax, nroTestes, porcValidacao)
	for serie=1:4
		EQMmedio = zeros(hMax-1,lagMax+1);
		EQMdesvio = zeros(hMax-1,lagMax+1);
		EQMtemp = zeros(1,10);
		datasetTreinamento = load("Dataset_series/serie" + serie + "_trein.txt");
		datasetTeste = load("Dataset_series/serie"+ serie + "_test.txt");
		for h=2:hMax
			for lag=0:lagMax
				fprintf("serie: %d h: %d lag: %d\n", serie, h,lag);
				parfor i=1:nroTestes
					[Xtr,Ydtr,Xvl,Ydvl,Xts] = processaDados(datasetTreinamento, datasetTeste, lag, porcValidacao);
					mlp = Mlp(h,nepMax,alfaInicial);
					mlp.treinamento(Xtr,Ydtr,Xvl,Ydvl);
					mlp.teste(Xts);
					erro = mlp.Y(1:end-1,1) - datasetTeste(2:end,1);
					EQMtemp(i) = 1/size(Xts,1)*sum(sum(erro.*erro));
				end
				EQMmedio(h-1,lag+1) = mean(EQMtemp);
				EQMdesvio(h-1,lag+1) = std(EQMtemp);
			end
		end
		save("EQMmedioAlfaBissecaoSerie" + serie + ".mat","EQMmedio");
		save("EQMdesvioAlfaBissecaoSerie" + serie + ".mat","EQMdesvio");
	end
end

%{
Função responsável por testar a MLP com valores definidos para h (número de
neurónios) e lag (número de entradas atrasadas) para uma determinada série
temporal. São executados <nroTestes> testes, sendo salvo em um arquivo a
média dos EQM's e o desvio padrão desses testes.
Parâmetros
serie: Indice da série temporal para qual a rede será testada;
h: Número de neurónios com o qual a rede será testada;
lag: Número de entradas atrasadas para o qual a rede será testada;
nepMax: Número máximo de épocas para o treinamento da rede que será
testada;
alfaInicial: valor do alfa inicial com o qual a rede será inicializada;
nroTestes: Número de testes que serão realizados com a rede;
porcValidacao: Porcentagens de dados de treinamento que serão utilizados
para validação;
Saídas salvas em arquivos
EQMmedioSerie.mat: Média dos EQM's testes realizados para uma dada série
EQMdesvioSerie.mat: Desvio padrão dos EQM's dos testes realizados
nepConvergenciaMedia: Média de épocas necessárias para a rede convergir;
nepConvergenciaDesvio: Desvio padrão do número de épocas para convergir;
%}
function testaMlp(serie,h,lag,nepMax,alfaInicial,nroTestes,porcValidacao)
	datasetTreinamento = load("Dataset_series/serie" + serie + "_trein.txt");
	datasetTeste = load("Dataset_series/serie"+ serie + "_test.txt");
	[Xtr,Ydtr,Xvl,Ydvl,Xts] = processaDados(datasetTreinamento, datasetTeste, lag, porcValidacao);
	Ydts = datasetTeste(2:end,1);
	EQMtemp = zeros(1,nroTestes);
	nepConvergenciaTemp = zeros(1,nroTestes);
	parfor i=1:nroTestes
		fprintf("serie: %d h: %d lag: %d teste: %d\n",serie, h,lag,i);
		mlp = Mlp(h,nepMax,alfaInicial);
		mlp.treinamento(Xtr,Ydtr,Xvl,Ydvl);
		mlp.teste(Xts);
		erro = mlp.Y(1:end-1,1) - Ydts;
		EQMtemp(i) = 1/size(Xts,1)*sum(sum(erro.*erro));
		nepConvergenciaTemp(i) = mlp.nepConvergencia;
	end
	EQMmedio = mean(EQMtemp);
	EQMdesvio = std(EQMtemp);
	save("EQMmedio" + serie + ".mat","EQMmedio");
	save("EQMdesvio" + serie + ".mat","EQMdesvio");
	nepConvergenciaMedia = mean(nepConvergenciaTemp);
	nepConvergenciaDesvio = std(nepConvergenciaTemp);
	save("nepConvergenciaMedia" + serie + ".mat","nepConvergenciaMedia");
	save("nepConvergenciaDesvio" + serie + ".mat","nepConvergenciaDesvio");
end

%Traduz a saída da classificação de binária para real
function acerto = traduzClasse(Y,Ydts)
	N = length(Y);
	correto = 0;
	[~,I] = max(Y,[],2);
	[~,Id] = max(Ydts,[],2);
	for i=1:N
		if (I(i) == Id(i))
			correto = correto+1;
		end
	end
	acerto = correto/N;
end