%Função que chama os testes
function teste()
	alfa = [0.1,0.25,0.5,1];
	nEpocasMax = [50,100,250,500,1000,10000,50000,100000];
	testaPerceptron(alfa,nEpocasMax)
end

%Rotina de teste para a função perceptron
function testaPerceptron(alfa,nEpocasMax)
	treinamento = load("dados/iris_treinamento.txt");
	teste = load("dados/iris_teste.txt");
	[Xtr,Ydtr,Xvl,Ydvl,Xts,Ydts] = processaDados(treinamento,teste,0);
	Nts = size(Xts,1);
	Xts = [Xts, ones(Nts,1)];
	EQMtrFinal = zeros(length(alfa),length(nEpocasMax));
	acerto = zeros(length(alfa),length(nEpocasMax));
	
	for i=1:length(nEpocasMax)
		grafico = figure('Name',['Número Épocas - ',int2str(nEpocasMax(i))],'NumberTitle','Off','Visible', 'off');
		for j=1:length(alfa)
			fprintf("N. Epocas: %d alfa: %.2f\n",nEpocasMax(i),alfa(j));
			%Treina
			[A,vErroTr,~] = perceptron(Xtr, Ydtr, Xvl, Ydvl,alfa(j),nEpocasMax(i));
			EQMtrFinal(j,i) = vErroTr(end);
			%Testa
			[Y,~] = calcSaida(Xts,Ydts,A);
			acerto(j,i) = traduzClasse(Y,Ydts);
			plot(vErroTr,'DisplayName',num2str(alfa(j),'%.2f\n'));
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