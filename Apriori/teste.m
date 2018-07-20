function itemsetsFrequentes = teste()
%Tentar entre 0.03 e 0.05
minSup = 0.03;

[nroItens,transacoes] = preProcessamentoSparse("datasets/t10i4d100.txt");
%[nroItens,transacoes] = preProcessamentoVotes("datasets/house-votes-84.txt");
apriori = Apriori(nroItens,transacoes,minSup);
itemsetsFrequentes = apriori.executa();
end