function testePar()
	%Genetico
	tipo='modificado';
	precisao=1.0e-6;
	nomeSelecao='classista';
	operacoes = ["uniforme troca";"umPonto reversiva";"doisPontos"; "pontual";"novos";"melhores";"aleatorios"];
	pMutacao=0.2;
	pCrossover=0.8;
	%Rede
	parametrosRede.intervaloH=[2,10];
	parametrosRede.intervaloLag=[0,15];
	parfor i=1:4
		%Dados
		datasetTreinamento = load("series/serie"+i+"_trein.txt");
		%Executa genético
		genetico = Genetico(tipo,precisao,nomeSelecao,operacoes,pMutacao,pCrossover,parametrosRede);
		genetico.executa(2500,350,datasetTreinamento);
		parsave("GA-Serie"+i,genetico);
	end
end

function parsave(path,genetico)
	save(path,"genetico");
end