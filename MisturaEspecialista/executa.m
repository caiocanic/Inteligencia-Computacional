function executa()
	%Parâmetros Internos
	lagMax = 20;
	nVlMax = 25;
	m = 2;
	he = [2 2];
	
	%Carrega os dados
	dados = load("treinamento.txt");
	lag = ProcessaDados.achaLag(dados,lagMax);
	dadosLag = ProcessaDados.adicionaLag(dados,lag);
	disp(dadosLag);
	
	
	kFolds = ProcessaDados.geraKFolds(dados,10);
	%{
	Xtr = [1 1;1 0;0 1;0 0];
	Ydtr = [0;1;1;0];
	Xvl = [];
	Ydvl = [];
	Ym = mistura(Xtr,Ydtr,m,he,100);
	%}
end