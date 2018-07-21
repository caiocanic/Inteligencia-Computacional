function [aprioriExemplo,aprioriVotes,aprioriSparse] = teste()
	%Tentar entre 0.03 e 0.01 para os Sparse.
	%O dataset Votes necessita de um suporte alto, já que a maioria dos
	%itens são bem frequentes devido a codificação utilizada (>=0.30).
	minSup = [0.20,0.45,0.035];
	minConf = 0;

	%Dataset de exemplo
	fprintf("Executando para dataset de exemplo\n");
	[nroItens,transacoes] = preProcessamentoSparse("datasets/exemplo.txt");
	aprioriExemplo = Apriori(nroItens,transacoes,minSup(1),minConf);
	aprioriExemplo.executa();
	save('resultados/aprioriExemplo.mat','aprioriExemplo');
	
	%Dataset Votes
	fprintf("Executando para dataset Votes\n");
	[nroItens,transacoes] = preProcessamentoVotes("datasets/house-votes-84.txt");
	aprioriVotes = Apriori(nroItens,transacoes,minSup(2),minConf);
	aprioriVotes.executa();
	save('resultados/aprioriVotes.mat','aprioriVotes');
	
	%Dataset Sparse
	fprintf("Executando para dataset Sparse\n");
	[nroItens,transacoes] = preProcessamentoSparse("datasets/t25i10d10.txt");
	aprioriSparse = Apriori(nroItens,transacoes,minSup(3),minConf);
	%aprioriSparse.executa();
	save('resultados/aprioriSparse.mat','aprioriSparse');
end