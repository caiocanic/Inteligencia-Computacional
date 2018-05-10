%Calcula a saída do perceptron
function [Y,erro] = calcSaida(X,Yd,A,funcao)
	Yin = X*A';
	if funcao == 'sigmoid' 
		Y = 1./(1+exp(-Yin));
	elseif funcao == 'softmax'
		ex = exp(Yin);
		Y = ex./sum(ex,2);
	end
	erro = Y-Yd;
end