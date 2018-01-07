%{
Classe responsável pelo objeto que representa uma Multilayer Perceptron.
Atributos
h: Número de neurónios da rede;
A: Matriz de pesos das entradas;
B: Matriz de pesos da camada de saída;
Y: Saída fornecida pela rede;
EQM: Erro quadrático médio das saídas fornecidas em relação a desejada;
%}
classdef Mlp < handle
	properties (SetAccess = private)
		h;
		A;
		B;
		dJdA;
		dJdB;
		alfa;
		Y;
		EQM;
	end
	methods
		%{
		Método contrutor
		Parâmetros
		h: Número de neurónios da rede;
		A: Matriz de pesos das entradas;
		B: Matriz de pesos da camada de saída;
		Saída
		mlp: Objeto do tipo Mlp com os atribútos equivalentes aos parâmetros
		passados ao construtor;
		%}
		function mlp = Mlp(h,A,B)
			mlp.h = h;
			mlp.A = A;
			mlp.B = B;
			mlp.alfa = Alfa(0.1);
		end
		
		%{
		Função auxiliar para o cálculo da saída da rede.
		Parâmetros
		rede: Objeto do tipo Mlp para o qual a saída será calculado;
		X: Conjunto de dados para o qual se deseja calcular a saída da rede;
		Yd: Saída desejada para a rede;
		Saída
		Y: Saída da rede para o conjunto de dados X;
		EQM: Erro quadrático médio de Y em relação a Yd;
		%}
		function calcSaida(mlp,X,Yd)
			[N,~] = size(X);
			X = [ones(N,1),X];
			Zin = X*mlp.A';
			Z = tanh(Zin);
			Yin = [ones(N,1),Z]*mlp.B';
			mlp.Y = sigmf(Yin,[1,0]);
			erro = mlp.Y - Yd;
			mlp.EQM = 1/N*sum(sum(erro.*erro));
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
		function treinamento(mlp,nepMax,Xtr,Ydtr)
			alfaT = 0.1;
			nep = 1;
			Ntr = size(Xtr,1);
			%Inicia Treinamento
			[mlp.dJdA, mlp.dJdB] = calcGrad(Xtr,Ydtr,mlp.A,mlp.B,Ntr);
			mlp.calcSaida(Xtr,Ydtr);
			EQMtr(nep) = mlp.EQM;
			while EQMtr(nep) > 1.0e-5 && nep < nepMax
				nep = nep+1;
				%Cálcula o alfa pela bissecao
				mlp.alfa.bissecao(mlp,Xtr,Ydtr,Ntr);
				%Atualiza os pesos
				mlp.A = mlp.A - alfaT*mlp.dJdA;
				mlp.B = mlp.B - alfaT*mlp.dJdB;
				%Recálcula o gradiente
				[mlp.dJdA, mlp.dJdB] = calcGrad(Xtr,Ydtr,mlp.A,mlp.B,Ntr);
				%Cálcula o erro
				mlp.calcSaida(Xtr,Ydtr);
				EQMtr(nep) = mlp.EQM;
				fprintf("EQMtr: %f\n",EQMtr(nep));
			end
		end
	end
end