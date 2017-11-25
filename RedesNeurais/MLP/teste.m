function teste()
	
	hMax=12;
	nepMax=20000;
	alfaInicial=1;
	lagMax = 15;
	nroTestes = 10;
	porcValidacao = 0.3;
	%testaMlp(hMax, nepMax, alfaInicial, lagMax, nroTestes, porcValidacao);
	
	%
	h=5;
	nepMax=20000;
	alfaInicial=0.1;
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

function testaMlp(hMax, nepMax, alfaInicial, lagMax, nroTestes, porcValidacao)
	for serie=3:4
		EQMmedio = zeros(hMax-1,lagMax+1);
		EQMdesvio = zeros(hMax-1,lagMax+1);
		EQMtemp = zeros(1,10);
		datasetTreinamento = load("Dataset_series/serie" + serie + "_trein.txt");
		datasetTeste = load("Dataset_series/serie"+ serie + "_test.txt");
		for h=2:hMax
			for lag=0:lagMax
				fprintf("serie: %d h: %d lag: %d\n", serie, h,lag);
				for i=1:nroTestes
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
		save("EQMmedioAlfaGoldenSerie" + serie + ".mat","EQMmedio");
		save("EQMdesvioAlfaGoldenSerie" + serie + ".mat","EQMdesvio");
	end
end