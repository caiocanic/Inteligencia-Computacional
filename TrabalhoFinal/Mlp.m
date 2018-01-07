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
			mlp.Y = tanh(Yin);
			erro = mlp.Y - Yd;
			mlp.EQM = 1/N*sum(sum(erro.*erro));
		end
	end
end