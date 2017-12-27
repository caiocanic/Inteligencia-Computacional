function teste()
representacao = 'binária';
nomeSelecao = 'roleta';
nomeFuncao = 'gold';
intervaloBusca = [-2,2;-2,2];
precisao=1.0e-4;
pCrossover=0.8;
pMutacao=0.2;
tamanhoPopulacao=250;

genetico = Genetico(nomeFuncao,intervaloBusca,precisao,representacao,nomeSelecao,pMutacao,pCrossover);
inicializaPopulacao(genetico,tamanhoPopulacao);
geraFenotipo(genetico);
calcFitness(genetico);
seleciona(genetico);
genetico.selecao.pares
end