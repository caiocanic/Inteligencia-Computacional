%Retorna o grádiente para a função sigmoid e softmax
function dJdA = grad(X,Yd,A,N,funcao)
	[Y,erro] = calcSaida(X,Yd,A,funcao);
	if funcao == 'sigmoid'
		dJdA = 1/N*(erro.*((1-Y).*Y))'*X;
	elseif funcao == 'softmax'
		%dJdA = 1/N*(erro.*derivada'*X;
		[N,ns] = size(Y);
		ne = size(X,2);
		dJdA = zeros(ns,ne);
		for k=1:ns
			derivada=zeros(N,ns);
			for m=1:ns
				if k == m
					derivada(:,k) = derivada(:,k)+(erro(:,m).*((1-Y(:,k)).*Y(:,m)));
				else
					derivada(:,k) = derivada(:,k)+(erro(:,m).*((-Y(:,k)).*Y(:,m)));
				end
			end
			dJdA(k,:) = 1/N*(derivada(:,k)'*X);
		end
	end
end