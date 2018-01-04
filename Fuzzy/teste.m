%{
Fun��o aonde foram implementadas as rotinas de teste do Fuzzy.
##O que foi feito##
Para cada s�rie e para cada lag de 0 a 5, foram criados um Sistema de Infer�ncia 
Fuzzy (FIS). Cada FIS possui um n�mero de vari�veis de entrada igual ao 
n�mero de entradas do conjunto de dados, ou seja, lag+1 vari�veis de
entrada, e uma �nica vari�vel de sa�da. Para cada vari�vel de entrada foram
cri�das duas fun��es de pertin�ncias do tipo "Generalized bell-shaped" e 
para vari�vel de sa�da, foi utilizado uma fun��o linear. Quanto as regras, 
foram criadas todas as combina��es poss�veis em rela��o as fun��es de 
pertin�ncia utilizando o conector AND.
Todas as fun��e de pertin�ncia foram criadas com os par�metros [0.5 2 0] e 
[0.5 2 1]. Para adequar os par�metros das fun��es a cada s�rie temporal,
foi utilizada a fun��o anfis, que utiliza o m�do backpropagation para 
determinar os par�metros ideias das fun��es de pertin�ncia.
##Resultados##
Como j� dito, para cada s�rie e lag foram criados um FIS. Ap�s o
treinamento, esse FIS ent�o foi testado e o resultado armazenado em uma
matriz. Assim, foi poss�vel determinar o lag que gerou o melhor FIS para
cada s�rie.
%}
function teste()
	porcValidacao = 0.3;
	serieMax = 4;
	lagMax = 5;
	EQM = ones(serieMax,lagMax);
	for serie=1:serieMax
		datasetTreinamento = load("Dataset_series/serie" + serie + "_trein.txt");
		datasetTeste = load("Dataset_series/serie" + serie + "_test.txt");
		for lag=0:lagMax
			fprintf("s�rie: %d lag: %d\n",serie,lag);
			[Xtr,Ydtr,Xvl,Ydvl,Xts,Ydts] = processaDados(datasetTreinamento, datasetTeste,lag,porcValidacao);
			[Nts,ne] = size(Xts);
			%Gera um FIS sugeno vazio
			fis = newfis('Preditor','FISType','sugeno');
			%Adiciona as vari�veis e fun��es de pertinencia para cada entrada
			for var=1:lag+1
				fis = addvar(fis,'input',"entrada"+(lag+1),[0,1]);
				fis = addmf(fis,'input',var,"in"+var+"mf1",'gbellmf', [0.5 2 0]);
				fis = addmf(fis,'input',var,"in"+var+"mf2",'gbellmf', [0.5 2 1]);
			end
			%Adiciona a vari�vel de sa�da e suas fun��es de pertin�ncia lineares
			fis = addvar(fis,'output',"saida",[0,1]);
			for i=1:2^ne
				param = zeros(1,ne+1);
				fis = addmf(fis,'output',1,"out1mf"+i,'linear', param);
			end
			%Adiciona as regras
			listaRegras = geraRegras(ne);
			fis = addrule(fis,listaRegras);
			%Treina o FIS - Utiliza o m�todo backpropagation para encontrar
			%os parametros ideais para as fun��es de pertin�ncia
			opt = anfisOptions('InitialFIS',fis,'EpochNumber',100,'ErrorGoal',1.0e-3,'ValidationData',[Xvl,Ydvl]);
			[~,~,~,fis,~] = anfis([Xtr,Ydtr],opt);
			%O FIS retornado � o que gera menor erro de valida��o.
			%Testa o FIS
			Yts = evalfis(Xts,fis);
			erro = Yts-Ydts;
			EQM(serie,lag+1) = 1/Nts*sum(sum(erro.*erro));
			writefis(fis,"FIS/FISserie"+serie+"lag"+lag);
		end
		save("EQM.mat","EQM");
	end
end

%{
Fun��o auxiliar criada para gerar a lista de regras que ser� adicionada ao
FIS.
Par�metro
ne: N�mero de entradas do conjunto de dados
Sa�da
listaRegras = matriz que representa as regras que ser�o adicionadas ao FIS.
%}
function listaRegras = geraRegras(ne)
	regras = permn([1 2],ne);
	consequente = (1:2^ne)';
	weightConections = ones(2^ne,2);
	listaRegras = [regras, consequente, weightConections];
end