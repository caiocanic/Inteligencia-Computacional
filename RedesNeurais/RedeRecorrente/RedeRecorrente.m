%{
Classe responsável pelo objeto encarregado de representar uma rede neural
com recorrência externa global;
Atributos
h: Número de neurônios da rede;
L: Número de atrasos da rede;
nepMax: Número de épocas máxima para a etapa de treinamento;
alfa: Taxa de aprendizagem;
A: Matriz de pesos das entradas atrasadas;
B: Matriz de pesos das entradas externas;
C: Matriz de pesos da camada de saída;
Y: Saída da rede;
Yold: Saída atrasada da rede, serve como entrada interna;
%}
classdef RedeRecorrente < handle
	properties (SetAccess = private)
		h;
		L;
		nepMax;
		alfa;
		A;
		B;
		C;
		Yts;
	end
	properties
		Yold;
	end
	methods
		%{
		Método construtor da RNN
		Parâmetros
		h: Número de neurônios da rede;
		L: Número de atrasos da rede;
		nepMax: Número de épocas máxima para a etapa de treinamento;
		alfaInicial: Valor inicial para a taxa de aprendizagem;
		Saída
		rede: Objeto do tipo RedeRecorrente com os atributos inicializados
		segundo os parâmetros da função;
		%}
		function rede = RedeRecorrente(h,L,nepMax,alfaInicial)
			rede.h = h;
			rede.L = L;
			rede.nepMax = nepMax;
			rede.alfa = alfaInicial;
		end
		
		%{
		Função responsável pela etapa de treinamento da RNN
		Parâmetros
		rede: Objeto do tipo RedeRecorrente, equivale a rede para qual será
		feito o treinamento;
		Xtr: Conjunto de dados de entrada;
		Ydtr: Saída desejada para o conjunto Xtr;
		%}
		function treinamento(rede,Xtr,Ydtr)
			nep=1;
			[Ntr,netr] = size(Xtr);
			ns = size(Ydtr,2);
			%Adiciona o bias
			Xtr = [Xtr, ones(Ntr,1)];
			%Inicializa as matrizes de pesos A, B e C
			rede.A = rands(rede.h,(ns*rede.L))/5;
			rede.B = rands(rede.h,netr+1)/5;
			rede.C = rands(ns,rede.h+1)/5;
			%Inicializa a matriz de entradas atrasadas
			rede.Yold = zeros(ns*rede.L,1);
			%Inicia Treinamento
			[dJdA, dJdB, dJdC, EQMtr(nep)] = calcGrad(rede,Xtr,Ydtr,Ntr,netr,ns);
			while EQMtr(nep) > 1.0e-5 && nep < rede.nepMax
				nep = nep+1;
				%Atualiza os pesos
				rede.A = rede.A - rede.alfa*dJdA;
				rede.B = rede.B - rede.alfa*dJdB;
				rede.C = rede.C - rede.alfa*dJdC;
				%Resseta o Yold.
				rede.Yold(:) = 0;
				%Recálcula o gradiente e o EQM
				[dJdA, dJdB, dJdC, EQMtr(nep)] = calcGrad(rede,Xtr,Ydtr,Ntr,netr,ns);
				fprintf("EQMtr: %f\n",EQMtr(nep));
			end
		end
		
		function EQMts = teste(rede,Xts,Ydts)
			[rede.Yts, EQMts] = calcSaida(rede,Xts,Ydts);
		end
	end
	methods (Access = private)
		function [Y,EQM] = calcSaida(rede,X,Yd)
			[N,ns] = size(X);
			Y = zeros(N,1);
			vetErro = zeros(N,1);
			X = [X, ones(N,1)];
			for t=1:N
				U = X(t,:)';
				S = rede.A*rede.Yold + rede.B*U;
				Z = tanh(S);
				Y(t,:) = rede.C*[Z;1];
				vetErro(t) = Y(t,:)-Yd(t,:);
				rede.Yold(2:end) = rede.Yold(1:end-1);
				rede.Yold(1:rede.L:(ns-1)*rede.L+1) = Y(t);
			end
			EQM = 1/N*sum(sum(vetErro.*vetErro))/N;
		end
	end
end