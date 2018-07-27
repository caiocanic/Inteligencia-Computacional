%Falta fazer a etapa de teste
%Adicionar validação aos especialistas
%he sempre deve ser um vetor de mesmo tamanho que m
function Ym = mistura(Xtr,Ydtr,m,he,nepMax)
	%Determina # instâncias, entradas e saídas
	[Ntr,netr]=size(Xtr);
	ns=size(Ydtr,2);
	%inicializa Rede Gating
	gating = Mlp("linear","softmax",netr,nepMax*10,0.1);
	% Inicializa especialista
	especialista = cell(1,m);
	for i=1:m
		especialista{i} = Mlp("tangente","linear",he,nepMax*100,0.1);
	end
	
	%Calcula saída da gating
	gating.inicializaPesos([netr netr],[m netr]);
	gating.teste(Xtr);
	%Calcula saída dos especialistas, da mistura e verossimilhança
	Ym=zeros(Ntr,ns);
	Py = zeros(Ntr,m);
	for i=1:m
		%Calcula saída do especialista
		especialista{i}.inicializaPesos([he(i) netr],[ns he(i)]);
		especialista{i}.teste(Xtr);
		%Calcula saída da mistura
		Ym = Ym + especialista{i}.Y.*gating.Y(:,i);
		%Calcula a função de verossimilhança
		diff = Ydtr-especialista{i}.Y;
		Py(:,i) = exp(sum(-diff.*diff,2));
	end
	
	likelihoodAnt= 0;
	likelihood= sum(log(sum(gating.Y.*Py,2)));
	%Atualiza a mistura até que a likelihood se estabilise ou atinga o
	%número de épocas
	nep=0;
	while abs(likelihood-likelihoodAnt)>1e-6 && nep<nepMax
		nep=nep+1;
		likelihoodAnt = likelihood;
		%Passo E
		YgdAux = gating.Y.*Py;
		Ygd = YgdAux./(sum(YgdAux,2)*ones(1,m));
		%Passo M
		%Atualiza a gating
		gating.treinamento(Xtr,Ygd,[],[],1,ones(size(Ydtr)));
		%Recalcula saída dos especialistas, da mistura e verossimilhança
		Ym=zeros(Ntr,ns);
		Py = zeros(Ntr,m);
		for i=1:m
			%Atualiza os especialistas
			especialista{i}.treinamento(Xtr,Ydtr,[],[],1,Ygd(:,i));
			%Recalcula a saída da mistura
			Ym = Ym + especialista{i}.Y.*gating.Y(:,i);
			%Recalcula a função de verossimilhança
			diff = Ydtr-especialista{i}.Y;
			Py(:,i) = exp(sum(-diff.*diff,2));
		end
		likelihood= sum(log(sum(gating.Y.*Py,2)));
	end
end