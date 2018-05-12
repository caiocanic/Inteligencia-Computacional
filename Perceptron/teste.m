%Função que chama os testes
function teste()
	alfaInicial = [0.1,0.25,0.5,1];
	nEpocasMax = [50,100,250,500,1000,10000,50000,100000];
	funcao = 'softmax';
	nroTestes=25;
	%testaPerceptronParametros(alfaInicial,nEpocasMax,funcao)
	testaPerceptronAutomatico(funcao,nroTestes)
end

%Rotina de testes para os parâmetros da função perceptron
function testaPerceptronParametros(alfaInicial,nEpocasMax,funcao)
	treinamento = load("dados/iris_treinamento.txt");
	teste = load("dados/iris_teste.txt");
	[Xtr,Ydtr,Xvl,Ydvl,Xts,Ydts] = processaDados(treinamento,teste,0);
	Nts = size(Xts,1);
	Xts = [Xts, ones(Nts,1)];
	EQMtrFinal = zeros(length(alfaInicial),length(nEpocasMax));
	acerto = zeros(length(alfaInicial),length(nEpocasMax));
	
	for i=1:length(nEpocasMax)
		grafico = figure('Name',['Número Épocas - ',int2str(nEpocasMax(i))],'NumberTitle','Off','Visible', 'off');
		for j=1:length(alfaInicial)
			fprintf("N. Epocas: %d alfa: %.2f\n",nEpocasMax(i),alfaInicial(j));
			%Treina
			[A,vErroTr,~] = perceptron(Xtr, Ydtr, Xvl, Ydvl,alfaInicial(j),nEpocasMax(i),funcao);
			EQMtrFinal(j,i) = vErroTr(end);
			%Testa
			[Y,~] = calcSaida(Xts,Ydts,A,funcao);
			acerto(j,i) = traduzClasse(Y,Ydts);
			plot(vErroTr,'DisplayName',num2str(alfaInicial(j),'%.2f\n'));
			hold on;
		end
		save('EQMtrfFinal.mat','EQMtrFinal');
		save('acerto.mat','acerto');
		hold off;
		title("Perceptron - "+int2str(nEpocasMax(i))+" Épocas");
		xlabel("Épocas");
		ylabel("EQM");
		legend('show','Location','best');
		saveas(grafico,[int2str(nEpocasMax(i)),'.png']);
	end
end

%Rotina de testes para o Perceptron com parametrização automática
function testaPerceptronAutomatico(funcao,nroTestes)
	treinamento = load("dados/iris_treinamento.txt");
	teste = load("dados/iris_teste.txt");
	[Xtr,Ydtr,Xvl,Ydvl,Xts,Ydts] = processaDados(treinamento,teste,0.3);
	Nts = size(Xts,1);
	Xts = [Xts, ones(Nts,1)];
	resultados = zeros(nroTestes,2);
	
	for i=1:nroTestes
		grafico = figure('Name',['Automático - Teste ',int2str(i)],'NumberTitle','Off','Visible', 'off');
		fprintf("Teste %d\n",i);
		%Treina
		[A,vErroTr,vErroVl,nEp] = perceptron(Xtr, Ydtr, Xvl, Ydvl,[],100000,funcao);
		%Testa
		[Y,~] = calcSaida(Xts,Ydts,A,funcao);
		resultados(i,1) = traduzClasse(Y,Ydts);
		resultados(i,2) = nEp;
		plot(vErroTr,'DisplayName','EQMtr');
		hold on;
		plot(vErroVl,'DisplayName','EQMvl');
		hold off;
		title("Perceptron Automático - Teste "+int2str(i));
		xlabel("Épocas");
		ylabel("EQM");
		legend('show','Location','best');
		saveas(grafico,['teste',int2str(i),'.png']);
		save('resultados.mat','resultados')
	end
	resultados = sortrows(resultados); %#ok<NASGU>
	save('resultados.mat','resultados');
end

%Traduz a saída do perceptron de binária para real
function acerto = traduzClasse(Y,Ydts)
	N = length(Y);
	correto = 0;
	[~,I] = max(Y,[],2);
	[~,Id] = max(Ydts,[],2);
	for i=1:N
		if (I(i) == Id(i))
			correto = correto+1;
		end
	end
	acerto = correto/N;
end