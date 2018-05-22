%{
Função responsável pelo cálculo dos gradientes das matrizes de pesos A e B.
Parâmetros
X: Conjunto de dados de entrada;
Yd: Saída desejada para o conjunto de dados X;
A: Matriz de pesos da entrada;
funcA: Função de ativação da camada oculta;
B: Matriz de pesos da camada de saída;
funcB: Função de ativação da camada de saída;
N: Número de instâncias do conjunto de entrada;
Saídas
dJdA: Gradiente da matriz de pesos A;
dJdB: Gradiente da matriz de pesos B;
%}
function [dJdA, dJdB] = calcGrad(X,Yd,A,funcA,B,funcB,N,h)
	%Calcula as saídas
	%Determina qual a função da camada oculta
	Zin = X*A';
	if funcA == "sigmoid"
		Z = 1./(1+exp(-Zin));
	elseif funcA == "tangente"
		Z = tanh(Zin);
	elseif funcA == "linear"
		Z = Zin;
	end
	%Determina qual a função da saída
	Yin = [Z,ones(N,1)]*B';
	if funcB == "sigmoid"
		Y = 1./(1+exp(-Yin));
	elseif funcB == "tangente"
		Y = tanh(Yin);
	elseif funcB == "linear"
		Y = Yin;
	elseif funcB == "softmax"
		ex = exp(Yin);
		Y = ex./sum(ex,2);
	end
	%Calcula o erro
	erro = Y-Yd;
	%Calcula as derivadas em relação a B
	if funcB == "sigmoid"
		dJdB = 1/N*(erro.*((1-Y).*Y))'*[Z,ones(N,1)];
		dJdZ = (erro.*((1-Y).*Y))*B;
	elseif funcB == "tangente"
		dJdB = 1/N*(erro.*(1-(Y.*Y)))'*[Z,ones(N,1)];
		dJdZ = (erro.*(1-(Y.*Y)))*B;
	elseif funcB == "linear"
		dJdB = 1/N*(erro)'*[Z,ones(N,1)];
		dJdZ = (erro)*B;
	elseif funcB == "softmax"
		[N,ns] = size(Y);
		dJdB = zeros(ns,h+1);
		derivada=zeros(N,ns);
		for k=1:ns
			for m=1:ns
				if k == m
					derivada(:,k) = derivada(:,k)+(erro(:,m).*((1-Y(:,k)).*Y(:,m)));
				else
					derivada(:,k) = derivada(:,k)+(erro(:,m).*((-Y(:,k)).*Y(:,m)));
				end
			end
			dJdB(k,:) = 1/N*(derivada(:,k)'*[Z,ones(N,1)]);
		end
		dJdZ = derivada*B;
	end
	dJdZ = dJdZ(:,1:end-1);
	%Calcula as derivadas em relação a A
	if funcA == "sigmoid"
		dJdA = 1/N*(dJdZ.*((1-Z).*Z))'*X;
	elseif funcA == "tangente"
		dJdA = 1/N*(dJdZ.*(1-(Z.*Z)))'*X;
	elseif funcA == "linear"
		dJdA = 1/N*(dJdZ'*X);
	end

end