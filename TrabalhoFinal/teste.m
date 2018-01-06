function teste()
%Genetico
tipo='modificado';
precisao=1.0e-6;
nomeSelecao='classista';
operacoes = ["uniforme troca";"umPonto reversiva";"doisPontos pontual";"nova";"melhores"];
pMutacao=0.1;
pCrossover=0.8;

%Rede
lag=11;
datasetTreinamento = load("database/series/serie1_trein.txt");
datasetTeste= load("database/series/serie1_test.txt");
[Xtr,Ydtr,Xts,Ydts] = processaDados(datasetTreinamento,datasetTeste,lag);
parametrosRede.h=4;
parametrosRede.ne = size(Xtr,2);
parametrosRede.ns = size(Ydtr,2);

genetico = Genetico(tipo,precisao,nomeSelecao,operacoes,pMutacao,pCrossover,parametrosRede);
genetico.executa(1000,250,Xtr,Ydtr);
figure(genetico.fitness.grafico)
genetico.fenotipo.melhor.calcSaida(Xts,Ydts);
genetico.fenotipo.melhor.EQM
end