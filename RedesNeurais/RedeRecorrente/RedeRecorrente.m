%{
Classe responsável pelo objeto encarregado de representar uma rede neural
com recorrência externa global;
Atributos
h: Número de neurônios da rede;
L: Número de atrasos da rede;
nepMax: Número de épocas máxima para a etapa de treinamento;
alfa: Taxa de aprendizagem;
A: Matriz de pesos das entradas atrasadas;
dJdA: Gradiente da matriz A;
B: Matriz de pesos das entradas externas;
dJdB: Gradiente da matriz B;
C: Matriz de pesos da camada de saída;
dJdC: Gradiente da matriz C;
Y: Saída da rede;
Yold: Saída atrasada da rede, serve como entrada interna;
%}
classdef RedeRecorrente < matlab.mixin.Copyable
	properties (SetAccess = private)
		h;
		L;
		nepMax;
		alfa;
		A;
		dJdA
		B;
		dJdB
		C;
		dJdC
		Yts;
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
			rede.alfa = Alfa(alfaInicial);
		end
		%{
		Função responsável pela etapa de treinamento e validação da RNN
		Parâmetros
		rede: Objeto do tipo RedeRecorrente, equivale a rede para qual será
		feito o treinamento;
		Xtr: Conjunto de dados de entrada;
		Ydtr: Saída desejada para o conjunto Xtr;
		Xvl: Conjunto de dados de validação;
		Ydvl: Saída desejada para Xvl;
		%}
		function treinamento(rede,Xtr,Ydtr,Xvl,Ydvl)
			nep=1;
			[Ntr,netr] = size(Xtr);
			ns = size(Ydtr,2);
			%Adiciona o bias
			Xtr = [Xtr, ones(Ntr,1)];
			%Inicializa as matrizes de pesos A, B e C
			rede.A = rands(rede.h,(ns*rede.L))/5;
			rede.B = rands(rede.h,netr+1)/5;
			rede.C = rands(ns,rede.h+1)/5;
			%Inicia Treinamento
			[rede.dJdA, rede.dJdB, rede.dJdC, rede.Yold, EQMtr(nep)] = calcGrad(rede,Xtr,Ydtr,Ntr,netr,ns);
			%Inicia a validação
			[~,EQMvl(nep)] = calcSaida(rede,Xvl,Ydvl);
			EQMvlBest = EQMvl(nep);
			while EQMtr(nep) > 1.0e-5 && nep < rede.nepMax
				nep = nep+1;
				%Calcula o alfa
				bissecao(rede.alfa,rede,Xtr,Ydtr,Ntr,netr,ns);
				%Atualiza os pesos
				rede.A = rede.A - rede.alfa.valor*rede.dJdA;
				rede.B = rede.B - rede.alfa.valor*rede.dJdB;
				rede.C = rede.C - rede.alfa.valor*rede.dJdC;
				%Salva os gradientes passados
				%dJdAOld = rede.dJdA;
				%dJdBOld = rede.dJdB;
				%dJdCOld = rede.dJdC;
				%Recálcula o gradiente e o EQM
				[rede.dJdA, rede.dJdB, rede.dJdC, rede.Yold, EQMtr(nep)] = calcGrad(rede,Xtr,Ydtr,Ntr,netr,ns);
				%Recálcula o alfa pelo ângulo
				%angulo(rede.alfa,rede,dJdAOld,dJdBOld,dJdCOld);
				%Validação
				[~,EQMvl(nep)] = calcSaida(rede,Xvl,Ydvl);
				if EQMvl(nep) < EQMvlBest
					ABest = rede.A;
					BBest = rede.B;
					CBest = rede.C;
					EQMvlBest = EQMvl(nep);
				end
				%fprintf("EQMtr: %f\n",EQMtr(nep));
			end
			%Grava o melhor valor da validação
			rede.A = ABest;
			rede.B = BBest;
			rede.C = CBest;
			
			%RedeRecorrente.plotEQM(EQMtr, EQMvl);
		end
		
		%{
		Função responsável pela etapa de teste da RNN
		Parâmetros
		rede: Objeto do tipo RedeRecorrente equivalente a rede que será
		testada
		Xts: Conjunto de dados de teste;
		Yts: Saída desejada para o teste;
		Saída
		EQMts: Erro quadratico médio do teste;
		%}
		function EQMts = teste(rede,Xts,Ydts)
			[rede.Yts, EQMts] = calcSaida(rede,Xts,Ydts);
		end
		
		%{
		Função auxiliar utilizada no cálculo do alfa. Atribui os valores
		dos parâmetros as matrizes de pesos.
		Parâmetros
		rede: Objeto do tipo RedeRecorrente para o qual as matrizes de
		pesos serão modificadas;
		A: Valor que será atribuído a matriz de pesos A;
		B: Valor que será atribuído a matriz de pesos B;
		C: Valor que será atribuído a matriz de pesos C;
		%}
		function setPesos(rede,A,B,C)
			rede.A = A;
			rede.B = B;
			rede.C = C;
		end
	end
	methods (Access = private)
		%{
		Função auxiliar que cálcula a saída da RNN
		Parâmetros
		rede: Objeto do tipo RedeRecorrente equivalente a rede para qual a
		saída será calculada
		X: Entrada para qual a saída será calculada
		Yd: Saída desejada de X;
		Saídas
		Y: Saída fornecida pela rede para X;
		EQM: Erro quadrático médio de Y em relação a Yd;
		%}	
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
	methods (Static = true)
		%{
		Função auxiliar utilizada para analisar o comportamento dos EQM's
		do treinamento e da validação por meio do plot desses valores.
		Parâmentros
		EQMtr: Erro quadrático médio do treinamento;
		EQMvl: Erro quadrático médio da validação;
		%}
		function plotEQM(EQMtr, EQMvl)
			plot(EQMtr);
			hold on;
			plot(EQMvl);
			hold off;
			pause;
		end
	end
end