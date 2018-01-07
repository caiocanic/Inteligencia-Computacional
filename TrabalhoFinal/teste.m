function teste()
	%Genetico
	tipo='modificado';
	precisao=1.0e-6;
	nomeSelecao='classista';
	operacoes = ["uniforme troca";"umPonto reversiva";"doisPontos pontual";"novos";"melhores";"aleatorios"];
	pMutacao=0.2;
	pCrossover=0.8;
	%Rede
	parametrosRede.intervaloH=[3,10];
	parametrosRede.treinamento = false;
	%Dados
	datasetTreinamento=load('database/classificação/wineTrain.txt');
	datasetTeste = load('database/classificação/wineTest.txt');
	nroClasses=3;
	[Xtr,Ydtr,Xvl,Ydvl,maxTr,minTr] = ProcessaClass.processaDatasetTreinamento(datasetTreinamento,nroClasses);
	[Xts,Ydts] = ProcessaClass.processaDatasetTeste(datasetTeste,nroClasses,maxTr,minTr);
	parametrosRede.ne = size(Xtr,2);
	parametrosRede.ns = size(Ydtr,2);
	
	%Executa
	genetico = Genetico(tipo,precisao,nomeSelecao,operacoes,pMutacao,pCrossover,parametrosRede);
	genetico.executa(2000,350,Xtr,Ydtr,Xvl,Ydvl);
	figure(genetico.fitness.grafico)

	%genetico.fenotipo.melhor.calcSaida(Xts,Ydts);
	%genetico.fenotipo.melhor.EQM
end