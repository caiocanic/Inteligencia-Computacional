function teste()
%Genetico
tipo='modificado';
precisao=1.0e-6;
nomeSelecao='classista';
operacoes = ["uniforme troca";"umPonto reversiva";"doisPontos pontual";"novos";"melhores";"aleatorios"];
pMutacao=0.1;
pCrossover=0.8;
%Rede
parametrosRede.intervaloH=[2,10];
parametrosRede.intervaloLag=[0,15];
%Dados
datasetTreinamento = load("series/serie1_trein.txt");
datasetTeste= load("series/serie1_test.txt");

%Executa
genetico = Genetico(tipo,precisao,nomeSelecao,operacoes,pMutacao,pCrossover,parametrosRede);
genetico.executa(1000,250,datasetTreinamento);
figure(genetico.fitness.grafico)

%genetico.fenotipo.melhor.calcSaida(Xts,Ydts);
%genetico.fenotipo.melhor.EQM
end