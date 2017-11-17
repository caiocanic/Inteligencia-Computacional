function teste()
	hMax=12;
	lagMax = 15;
	nroTestes = 10;
	porcValidacao = 0.3;
	testaMlp(hMax, lagMax, nroTestes, porcValidacao);
	
	%{
	h=3;
	lag=5;
	datasetTreinamento = load("Dataset_series/serie2_trein.txt");
	datasetTeste = load("Dataset_series/serie2_test.txt");
	[Xtr,Ydtr,Xvl,Ydvl,Xts] = processaDados(datasetTreinamento, datasetTeste, lag, porcValidacao);
	[A,B,Y] = mlp(Xtr,Ydtr,Xvl,Ydvl,Xts,h);
	%}
	%{
	plot(datasetTeste(2:end,1),'DisplayName','dataset');
	hold on;
	plot(Y(1:end-1,1),'DisplayName','Y');
	hold off;
	%}
end

function testaMlp(hMax, lagMax, nroTestes, porcValidacao)
	for serie=1:4
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
					[~,~,Y] = mlp(Xtr,Ydtr,Xvl,Ydvl,Xts,h);
					erro = Y(1:end-1,1) - datasetTeste(2:end,1);
					EQMtemp(i) = 1/size(Xts,1)*sum(sum(erro.*erro));
				end
				EQMmedio(h-1,lag+1) = mean(EQMtemp);
				EQMdesvio(h-1,lag+1) = std(EQMtemp);
			end
		end
		save("EQMmedioSerie" + serie,"EQMmedio");
		save("EQMdesvioSerie" + serie,"EQMdesvio");
	end
end