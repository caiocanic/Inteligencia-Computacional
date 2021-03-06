function teste()
	tipo = 'modificado';
	nroTestes=5;
	representacao = 'real';
	nomeSelecao = 'torneio';
	nomeFuncao = ["gold";"sumS";"deJong";"ackley";"bump";"rastrigin"];
	intervaloBusca = {[-2,2;-2,2];[-10,10;-10,10];[-2,2;-2,2];...
		[-32.768,32.768;-32.768,32.768];[0,10;0,10];[-5.12,5.12;-5.12,5.12]};
	precisao=1.0e-6;
	%operacoes = "";
	%operacoes = ["uniforme pontual";"nova";"troca";"umPonto"];
	operacoes = ["media soma";"melhor";"nova";"combinacao";"multiplicacao";"aleatoria"];
	pCrossover=0.8;
	pMutacao=0.10;
	geracoesMax = 500;
	tamanhoPopulacao=250;

	for i=1:size(nomeFuncao,1)
		resultado = zeros(nroTestes,3);
		for j=1:nroTestes
			fprintf("funcao: %s teste:%d\n",nomeFuncao(i),j);
			genetico = Genetico(tipo,char(nomeFuncao(i)),cell2mat(intervaloBusca(i)),precisao,representacao,nomeSelecao,operacoes,pMutacao,pCrossover);
			executa(genetico,geracoesMax,tamanhoPopulacao);
			resultado(j,1:2) = genetico.fenotipo.melhor;
			resultado(j,3) = genetico.funcao.calcula(genetico.fenotipo.melhor);
			saveas(genetico.fitness.grafico,['Resultados/Gráficos/',char(nomeFuncao(i)),num2str(j),'.png']);
			save("Resultados/Valores/"+nomeFuncao(i),"resultado");
		end
	end
end