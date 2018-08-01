%{
Classe que representa uma mistura de especialista. Os especialistas e a
rede gating são redes MLP.
Atributos
m: Número de especialistas
gating: Rede gating. É um objeto do tipo Mlp
especialistas: array de cells contendo os especialistas da mistura. São
	objetos Mlp.
Ym: Saída da mistura.
%}
classdef Mistura < handle
	properties
		m;
		gating;
		especialistas;
		Ym;
	end
	methods
		%{
		Função construtora.
		Parâmetros
		m: Número de especialistas.
		%}
		function mistura = Mistura(m)
			mistura.m = m;
		end
		
		%{
		Função que realiza o treinamento da mistua de especialistas.
		Atributos
		Xtr: Conjunto de dados de entrada do treinamento.
		Ydtr: Saída desejada para os conjunto de dados do treinamento.
		Xvl: Conjunto de dados de entrada para a validação.
		Ydvl: Saída desejada para o conjunto de dados da validação.
		he: Array 1xm contendo o número de neurônios de cada especialista.
		funcE: Array mx2 contendo as funções de ativação de cada
			especialista.
		nepMax: Número máximo de épocas para o treinamento da mistura. O
			número de épocas da rede gating e dos especialistas é multiplo
			desse número.
		%}
		function treinamento(mistura,Xtr,Ydtr,Xvl,Ydvl,nVlMax,he,funcE,nepMax)
			%Determina # instâncias, entradas e saídas
			[Ntr,netr]=size(Xtr);
			ns=size(Ydtr,2);
			%inicializa Rede Gating
			mistura.gating = Mlp("linear","softmax",netr,nepMax*10,0.1);
			% Inicializa especialista
			mistura.especialistas = cell(1,mistura.m);
			for i=1:mistura.m
				mistura.especialistas{i} = Mlp(funcE(i,1),funcE(i,2),he(i),nepMax*100,0.1);
			end
			
			%Calcula saída da gating
			mistura.gating.inicializaPesos([netr netr],[mistura.m netr]);
			mistura.gating.teste(Xtr);
			%Calcula saída dos especialistas, da mistura e verossimilhança
			mistura.Ym=zeros(Ntr,ns);
			Py = zeros(Ntr,mistura.m);
			for i=1:mistura.m
				%Calcula saída do especialista
				mistura.especialistas{i}.inicializaPesos([he(i) netr],[ns he(i)]);
				mistura.especialistas{i}.teste(Xtr);
				%Calcula saída da mistura
				mistura.Ym = mistura.Ym + mistura.especialistas{i}.Y.*mistura.gating.Y(:,i);
				%Calcula a função de verossimilhança
				diff = Ydtr-mistura.especialistas{i}.Y;
				Py(:,i) = exp(sum(-diff.*diff,2));
			end
			
			likelihoodAnt= 0;
			likelihood= sum(log(sum(mistura.gating.Y.*Py,2)));
			%Atualiza a mistura até que a likelihood se estabilise ou atinga o
			%número de épocas
			nep=0;
			while abs(likelihood-likelihoodAnt)>1e-6 && nep<nepMax
				nep=nep+1;
				likelihoodAnt = likelihood;
				%Passo E
				YgdAux = mistura.gating.Y.*Py;
				Ygd = YgdAux./(sum(YgdAux,2)*ones(1,mistura.m));
				%Passo M
				%Atualiza a gating
				mistura.gating.treinamento(Xtr,Ygd,[],[],1,ones(size(Ydtr)));
				%Recalcula saída dos especialistas, da mistura e verossimilhança
				mistura.Ym=zeros(Ntr,ns);
				Py = zeros(Ntr,mistura.m);
				for i=1:mistura.m
					%Atualiza os especialistas
					mistura.especialistas{i}.treinamento(Xtr,Ydtr,Xvl,Ydvl,nVlMax,Ygd(:,i));
					%Recalcula a saída da mistura
					mistura.Ym = mistura.Ym + mistura.especialistas{i}.Y.*mistura.gating.Y(:,i);
					%Recalcula a função de verossimilhança
					diff = Ydtr-mistura.especialistas{i}.Y;
					Py(:,i) = exp(sum(-diff.*diff,2));
				end
				likelihood= sum(log(sum(mistura.gating.Y.*Py,2)));
			end
		end
		
		%{
		Função que realiza a etapa de teste da mistura de especialista
		Atributos
		Xts: Conjunto de dados de teste.
		%}
		function teste(mistura,Xts)
			%Calcula saída da gating
			mistura.gating.teste(Xts);
			%Calcula saída dos especialistas e da mistura
			mistura.Ym=0;
			for i=1:mistura.m
				%Calcula saída do especialista
				mistura.especialistas{i}.teste(Xts);
				%Calcula saída da mistura
				mistura.Ym = mistura.Ym + mistura.especialistas{i}.Y.*mistura.gating.Y(:,i);
			end
		end
	end
end