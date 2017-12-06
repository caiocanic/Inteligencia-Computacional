%{
Função responsável por chamar a rotina de testes da RNN ou realizar apenas
um treinamento e teste para os dados parâmetros
%}
function teste()
	hMax=6;
	nepMax=5000;
	alfaInicial = 0.1;
	lagMax = 7;
	nroTestes = 10;
	porcValidacao = 0.3;
	%testaParametros(hMax, nepMax, alfaInicial, lagMax, nroTestes, porcValidacao);
	
	%
	h=6;
	lag=7;
	testaRede(3,h,lag,nepMax,alfaInicial,nroTestes,porcValidacao);
	%}
	%{
	plot(datasetTeste(2:end,1),'DisplayName','dataset');
	hold on;
	plot(mlp.Y(1:end-1,1),'DisplayName','Y');
	hold off;
	%}
end

%{
Função responsável por testar a RNN com diferentes valores de h (número de
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
		EQMtemp = zeros(1,nroTestes);
		datasetTreinamento = load("Dataset_series/serie" + serie + "_trein.txt");
		datasetTeste = load("Dataset_series/serie"+ serie + "_test.txt");
		for h=2:hMax
			for lag=1:lagMax
				fprintf("serie: %d h: %d lag: %d\n",serie, h,lag);
				parfor i=1:nroTestes
					[Xtr,Ydtr,Xvl,Ydvl,Xts,Ydts] = processaDados(datasetTreinamento, datasetTeste,porcValidacao);
					rede = RedeRecorrente(h,lag,nepMax,alfaInicial);
					treinamento(rede,Xtr,Ydtr,Xvl,Ydvl);
					EQMtemp(i) = teste(rede,Xts, Ydts);
				end
				EQMmedio(h-1,lag+1) = mean(EQMtemp);
				EQMdesvio(h-1,lag+1) = std(EQMtemp);
				save("EQMmedioAlfaBissecaoSerie" + serie + ".mat","EQMmedio");
				save("EQMdesvioAlfaBissecaoSerie" + serie + ".mat","EQMdesvio");
			end
		end
	end
end

%{
Função responsável por testar a RNN com valores definidos para h (número de
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
function testaRede(serie, h,lag,nepMax,alfaInicial,nroTestes,porcValidacao)
	datasetTreinamento = load("Dataset_series/serie" + serie + "_trein.txt");
	datasetTeste = load("Dataset_series/serie"+ serie + "_test.txt");
	[Xtr,Ydtr,Xvl,Ydvl,Xts,Ydts] = processaDados(datasetTreinamento, datasetTeste,porcValidacao);
	EQMtemp = zeros(1,nroTestes);
	nepConvergenciaTemp = zeros(1,nroTestes);
	for i=1:nroTestes
		fprintf("serie: %d h: %d lag: %d teste: %d\n",serie, h,lag,i);
		rede = RedeRecorrente(h,lag,nepMax,alfaInicial);
		treinamento(rede,Xtr,Ydtr,Xvl,Ydvl)
		EQMtemp(i) = teste(rede,Xts,Ydts);
		nepConvergenciaTemp(i) = rede.nepConvergencia;
	end
	EQMmedio = mean(EQMtemp);
	EQMdesvio = std(EQMtemp);
	nepConvergenciaMedia = mean(nepConvergenciaTemp);
	nepConvergenciaDesvio = std(nepConvergenciaTemp);
	save("EQMmedio" + serie + ".mat","EQMmedio");
	save("EQMdesvio" + serie + ".mat","EQMdesvio");
	save("nepConvergenciaMedia" + serie + ".mat","nepConvergenciaMedia");
	save("nepConvergenciaDesvio" + serie + ".mat","nepConvergenciaDesvio");
end