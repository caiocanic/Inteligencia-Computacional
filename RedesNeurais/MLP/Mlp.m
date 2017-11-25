%{
Classe responsável pelo objeto que representa uma Multilayer Perceptron.
Atributos
h: Número de neurónios da rede;
nepMax: Número máximo de épocas para a condição de parada;
alfa: Objeto da classe Alfa, representa a taxa de aprendizagem;
A: Matriz de pesos das entradas;
B: Matriz de pesos da camada de saída;
dJdA: Gradiente da matriz A;
dJdB: Gradiente da matriz B;
Y: Saída fornecida pela rede;
%}
classdef Mlp < handle
	properties (SetAccess = private)
		h;
		nepMax;
		alfa;
		A;
		B;
		dJdA;
		dJdB;
		Y;
	end
	methods
		%{
		Método contrutor
		Parâmetros
		h: Número de neurónios da rede;
		nepMax: Número máximo de épocas para a condição de parada;
		alfaInicial: Valor inicial da taxa de aprendizagem;
		Saída
		mlp: Objeto do tipo Mlp com os atribútos equivalentes aos parâmetros
		passados ao construtor;
		%}
		function mlp = Mlp(h,nepMax,alfaInicial)
			mlp.h = h;
			mlp.nepMax = nepMax;
			mlp.alfa = Alfa(alfaInicial);
		end
		
		%{
		Método que realiza a etapa de treinamento da rede Multilayer
		Perceptron. Ele é responsável por calcular os gradientes, calcular
		o alfa e atualizar os pesos. Além disso, o processo de validação
		tabém é feito neste método.
		Parâmetros
		mlp: Objeto do tipo Mlp equivalente a rede que será treina;
		Xtr: Conjunto de dados de entrada do treinamento;
		Ydtr: Saída desejada para os conjunto de dados do treinamento;
		Xvl: Conjunto de dados de entrada para a validação;
		Ydvl: Saída desejada para o conjunto de dados da validação;
		%}
		function treinamento(mlp,Xtr,Ydtr,Xvl,Ydvl)
			nep = 1;
			[Ntr,netr] = size(Xtr);
			[Nvl,~] = size(Xvl);
			ns = size(Ydtr,2);
			%Adiciona o bias
			Xtr = [Xtr, ones(Ntr,1)];
			Xvl = [Xvl, ones(Nvl,1)];
			%Inicializa as matrizes de pesos A e B
			mlp.A = rands(mlp.h,netr+1)/5;
			mlp.B = rands(ns,mlp.h+1)/5;
			%Inicia Treinamento
			[mlp.dJdA, mlp.dJdB] = calcGrad(Xtr,Ydtr,mlp.A,mlp.B,Ntr);
			mlp.Y = mlp.calcSaida(mlp.A,mlp.B,Xtr,Ntr);
			errotr = mlp.Y-Ydtr;
			EQMtr(nep) = 1/Ntr*sum(sum(errotr.*errotr));
			%Inicia Validação
			Yvl = mlp.calcSaida(mlp.A,mlp.B,Xvl,Nvl);
			errovl = Yvl-Ydvl;
			EQMvl(nep) = 1/Nvl*sum(sum(errovl.*errovl));
			EQMvlBest = EQMvl(nep);
			while EQMtr(nep) > 1.0e-5 && nep < mlp.nepMax
				nep = nep+1;
				%Cálcula o alfa pela razão áurea
				%mlp.alfa.golden(mlp,Xtr,Ydtr,Ntr);
				%Cálcula o alfa pela bissecao
				mlp.alfa.bissecao(mlp,Xtr,Ydtr,Ntr);
				%Atualiza os pesos
				Anew = mlp.A - mlp.alfa.valor*mlp.dJdA;
				Bnew = mlp.B - mlp.alfa.valor*mlp.dJdB;
				%Validação
				Yvl = mlp.calcSaida(Anew,Bnew,Xvl,Nvl);
				errovl = Yvl-Ydvl;
				EQMvl(nep) = 1/Ntr*sum(sum(errovl.*errovl));
				if EQMvl(nep) < EQMvlBest
					ABest = mlp.A;
					BBest = mlp.B;
					EQMvlBest = EQMvl(nep);
				end
				mlp.A = Anew;
				mlp.B = Bnew;
				%Recálcula o gradiente
				%dJdAOld = mlp.dJdA;
				%dJdBOld = mlp.dJdB;
				[mlp.dJdA, mlp.dJdB] = calcGrad(Xtr,Ydtr,mlp.A,mlp.B,Ntr);
				%Cálcula o alfa pelo ângulo entre os gradientes
				%mlp.alfa.angulo(dJdAOld,dJdBOld,mlp);
				%Cálcula o erro
				mlp.Y = mlp.calcSaida(mlp.A,mlp.B,Xtr,Ntr);
				errotr = mlp.Y-Ydtr;
				EQMtr(nep) = 1/Ntr*sum(sum(errotr.*errotr));
				%fprintf("EQMtr: %f\n",EQMtr(nep));
			end
			mlp.A = ABest;
			mlp.B = BBest;
			
			%mlp.plotEQM(EQMtr,EQMvl);
		end
		
		%{
		Método que realiza a etapa de teste da rede Multilayer Perceptron.
		Ele é reponsável por calcular a saída da rede para o conjunto de
		teste a partir das matrizes de pesos geradas pelo treinamento.
		Parâmetros
		mlp: Objeto do tipo Mlp equivalente a rede para qual deseja-se
		calcular a saída;
		Xts: Conjunto de dados de teste;
		%}
		function teste(mlp,Xts)
			[N,~] = size(Xts);
			%Adiciona o bias
			Xts = [Xts, ones(N,1)];
			mlp.Y = mlp.calcSaida(mlp.A,mlp.B,Xts,N);
		end
	end
	
	methods (Static = true, Access = private)
		%{
		Função auxiliar para o cálculo da saída da rede.
		Parâmetros
		A: Matriz de pesos da entrada;
		B: Matriz de pesos da camda de saída;
		X: Conjunto de dados para o qual se deseja calcular a saída da rede;
		N: Número de instâncias no conjunto X;
		Saída
		Y: Saída da rede para o conjunto de dados X dadas as matrizes de 
		pesos A e B;
		%}
		function Y = calcSaida(A,B,X,N)
			Zin = X*A';
			Z = tanh(Zin);
			Yin = [Z,ones(N,1)]*B';
			Y = tanh(Yin);
		end
		
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