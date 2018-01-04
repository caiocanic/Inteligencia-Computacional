%{
Função aonde foram implementadas as rotinas de teste do Fuzzy.
##O que foi feito##
Para cada série e para cada lag de 0 a 5, foram criados um Sistema de Inferência 
Fuzzy (FIS). Cada FIS possui um número de variáveis de entrada igual ao 
número de entradas do conjunto de dados, ou seja, lag+1 variáveis de
entrada, e uma única variável de saída. Para cada variável de entrada foram
criádas duas funções de pertinências do tipo "Generalized bell-shaped" e 
para variável de saída, foi utilizado uma função linear. Quanto as regras, 
foram criadas todas as combinações possíveis em relação as funções de 
pertinência utilizando o conector AND.
Todas as funçõe de pertinência foram criadas com os parâmetros [0.5 2 0] e 
[0.5 2 1]. Para adequar os parâmetros das funções a cada série temporal,
foi utilizada a função anfis, que utiliza o médo backpropagation para 
determinar os parâmetros ideias das funções de pertinência.
##Resultados##
Como já dito, para cada série e lag foram criados um FIS. Após o
treinamento, esse FIS então foi testado e o resultado armazenado em uma
matriz. Assim, foi possível determinar o lag que gerou o melhor FIS para
cada série.
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
			fprintf("série: %d lag: %d\n",serie,lag);
			[Xtr,Ydtr,Xvl,Ydvl,Xts,Ydts] = processaDados(datasetTreinamento, datasetTeste,lag,porcValidacao);
			[Nts,ne] = size(Xts);
			%Gera um FIS sugeno vazio
			fis = newfis('Preditor','FISType','sugeno');
			%Adiciona as variáveis e funções de pertinencia para cada entrada
			for var=1:lag+1
				fis = addvar(fis,'input',"entrada"+(lag+1),[0,1]);
				fis = addmf(fis,'input',var,"in"+var+"mf1",'gbellmf', [0.5 2 0]);
				fis = addmf(fis,'input',var,"in"+var+"mf2",'gbellmf', [0.5 2 1]);
			end
			%Adiciona a variável de saída e suas funções de pertinência lineares
			fis = addvar(fis,'output',"saida",[0,1]);
			for i=1:2^ne
				param = zeros(1,ne+1);
				fis = addmf(fis,'output',1,"out1mf"+i,'linear', param);
			end
			%Adiciona as regras
			listaRegras = geraRegras(ne);
			fis = addrule(fis,listaRegras);
			%Treina o FIS - Utiliza o método backpropagation para encontrar
			%os parametros ideais para as funções de pertinência
			opt = anfisOptions('InitialFIS',fis,'EpochNumber',100,'ErrorGoal',1.0e-3,'ValidationData',[Xvl,Ydvl]);
			[~,~,~,fis,~] = anfis([Xtr,Ydtr],opt);
			%O FIS retornado é o que gera menor erro de validação.
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
Função auxiliar criada para gerar a lista de regras que será adicionada ao
FIS.
Parâmetro
ne: Número de entradas do conjunto de dados
Saída
listaRegras = matriz que representa as regras que serão adicionadas ao FIS.
%}
function listaRegras = geraRegras(ne)
	regras = permn([1 2],ne);
	consequente = (1:2^ne)';
	weightConections = ones(2^ne,2);
	listaRegras = [regras, consequente, weightConections];
end