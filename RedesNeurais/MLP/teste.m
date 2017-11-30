%{
Função responsável por chamar a rotina de testes da MLP ou realizar apenas
um treinamento e teste para os dados parâmetros
%}
function teste()
	hMax=12;
	nepMax=20000;
	alfaInicial=0.1;
	lagMax = 15;
	nroTestes = 10;
	porcValidacao = 0.3;
	%testaMlp(hMax, nepMax, alfaInicial, lagMax, nroTestes, porcValidacao);
	
	%
	h=5;
	lag=6;
	datasetTreinamento = load("Dataset_series/serie1_trein.txt");
	datasetTeste = load("Dataset_series/serie1_test.txt");
	[Xtr,Ydtr,Xvl,Ydvl,Xts] = processaDados(datasetTreinamento, datasetTeste, lag, porcValidacao);
	mlp = Mlp(h,nepMax,alfaInicial);
	mlp.treinamento(Xtr,Ydtr,Xvl,Ydvl);
	mlp.teste(Xts);
	erro = mlp.Y(1:end-1,1) - datasetTeste(2:end,1);
	EQM = 1/size(Xts,1)*sum(sum(erro.*erro));
	disp(EQM);
	%}
	%{
	plot(datasetTeste(2:end,1),'DisplayName','dataset');
	hold on;
	plot(mlp.Y(1:end-1,1),'DisplayName','Y');
	hold off;
	%}
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
function testaMlp(hMax, nepMax, alfaInicial, lagMax, nroTestes, porcValidacao)
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