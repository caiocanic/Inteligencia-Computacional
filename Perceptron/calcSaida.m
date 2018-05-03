%Calcula a saída do perceptron
function [Y,erro] = calcSaida(X,Yd,A)
	Yin = X*A';
	Y = 1./(1+exp(-Yin));
	erro = Y-Yd;
end