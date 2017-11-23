%{
Função responsável pelo cálculo dos gradientes das matrizes de pesos A e B.
Parâmetros
X: Conjunto de dados de entrada;
Yd: Saída desejada para o conjunto de dados X;
A: Matriz de pesos da entrada;
B: Matriz de pesos da camada de saída;
N: Número de instâncias do conjunto de entrada;
Saídas
dJdA: Gradiente da matriz de pesos A;
dJdB: Gradiente da matriz de pesos B;
%}
function [dJdA, dJdB] = calcGrad(X,Yd,A,B,N)
	Zin = X*A';
	Z = tanh(Zin);
	Yin = [Z,ones(N,1)]*B';
	Y = tanh(Yin);
	erro = Y-Yd;
	dJdB = 1/N*(erro.*(1-Y.*Y))'*[Z,ones(N,1)];
	dJdZ = (erro.*(1-Y.*Y))*B;
	dJdZ = dJdZ(:,1:end-1);
	dJdA = 1/N*(dJdZ.*(1-Z.*Z))'*X;
end