function testePar()
%Genetico
tipo='modificado';
precisao=1.0e-6;
nomeSelecao='classista';
operacoes = ["uniforme troca";"umPonto reversiva";"doisPontos pontual";"novos";"melhores";"aleatorios"];
pMutacao=0.1;
pCrossover=0.8;

%Rede
lag=[10;9;11;15];
h=[5;6;4;4];

parfor i=1:4
	%Dados
	datasetTreinamento = load("database/series/serie"+i+"_trein.txt");
	datasetTeste= load("database/series/serie"+i+"_test.txt");
	[Xtr,Ydtr,Xts,Ydts] = processaSeries(datasetTreinamento,datasetTeste,lag(i));
	ne = size(Xtr,2);
	ns = size(Ydtr,2);
	parametrosRede = struct('h',h(i),'ne',ne,'ns',ns);
	%Executa genético
	genetico = Genetico(tipo,precisao,nomeSelecao,operacoes,pMutacao,pCrossover,parametrosRede);
	genetico.executa(2000,250,Xtr,Ydtr);
	genetico.fenotipo.melhor.calcSaida(Xts,Ydts);
	genetico.fenotipo.melhor.EQM
	parsave("GA - Série"+i,genetico);
end

end

function parsave(path,genetico)
	save(path,"genetico");
end