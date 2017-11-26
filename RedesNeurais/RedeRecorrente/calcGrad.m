%{
Função responsável pelo cálculo dos gradientes das matrizes de pesos da
RNN. Ao longo do processo também é realizada a propagação direta das
entradas e o cálculo do EQM.
Parâmetros
rede: Rede recorrente para qual os gradientes serão cálculados;
X: Conjunto de dados de entrada;
Yd: Saída desejada para o conjunto X;
N: Número de instâncias no conjunto X;
ne: Número de entradas externas da RNN;
ns: Número de saídas da RNN;
Saída
dJdA: Gradiente da matriz de pesos das entradas atrasadas;
dJdB: Gradiente da matriz de pesos das entradas externas;
dJdC: Gradiente da matriz de pesos da camada de saída;
Yold: Saída atrasada da rede;
EQM: Erro quadrático médio de Y em relação a Yd
%}
function [dJdA, dJdB, dJdC, Yold, EQM] = calcGrad(rede,X,Yd,N,ne,ns)
	hMaior = rede.h+1;
	%Inicializa matrizes de recorrência
	Yold = zeros(ns*rede.L,1);
	dYdCold = zeros(ns*rede.L,ns*(rede.h+1));
	dYdAold = zeros(ns*rede.L,rede.h*ns*rede.L);
	dYdBold = zeros(ns*rede.L,rede.h*(ns+1));
	%Inicializa matrizes auxiliares
	MatZ = zeros(ns,ns*(rede.h+1));
	dJTdC = zeros(1,ns*(rede.h+1));
	MatYold = zeros(rede.h,rede.h*ns*rede.L);
	dJTdA = zeros(1,rede.h*ns*rede.L);
	MatU = zeros(rede.h,rede.h*(ne+1));
	dJTdB = zeros(1,rede.h*(ne+1));
	vetErro = zeros(N,1);
	
	for t=1:N
		% propagacao direta
		U = X(t,:)';      % entrada externa atual
		d = Yd(t,:)';      % saidas desejadas
		S = rede.A*Yold + rede.B*U;
		Z = tanh(S);  % entradas para a camada de saida
		Y = rede.C*[Z;1];
		erro = Y-d;
		vetErro(t) = erro;
		dZdS = (1.0-Z.*Z);
		DiagdZdS = diag(dZdS);
		% calculo das derivadas de J em relacao a C(l,k)
		dZdC = DiagdZdS*rede.A*dYdCold;      %calculo de dZ/dC(l,k)
		for k = 1:ns
			MatZ(k,(k-1)*hMaior+1:k*hMaior) = [Z;1]';
		end
		dYdC = rede.C(:,1:rede.h)*dZdC + MatZ;     %calculo de dY/dC(l,k)
		dJdC = erro'*dYdC;               %calculo de dJ/dC
		dJTdC = dJTdC + dJdC;            %gradiente total
		% calculo das derivadas de J em relacao a A(r,k)
		for j = 1:rede.h		% comp bloco = c*L
			MatYold(j,(j-1)*ns*rede.L+1:j*ns*rede.L) = Yold';    % difere de processa.m
		end
		dZdA = DiagdZdS*(rede.A*dYdAold + MatYold);   %calculo de dZ/dA
		dYdA = rede.C(:,1:rede.h)*dZdA;                   %calculo de dY/dA
		dJdA = erro'*dYdA;                      %calculo de dJ/dA
		dJTdA = dJTdA + dJdA;                   %gradiente total
		% calculo das derivadas de J em relacao a B(r,i)
		for i = 1:rede.h
			MatU(i,(i-1)*(ne+1)+1:i*(ne+1)) = U';
		end
		dZdB = DiagdZdS*(rede.A*dYdBold + MatU);      %calculo de dZ/dB
		dYdB = rede.C(:,1:rede.h)*dZdB;                    %calculo de dY/dB
		dJdB = erro'*dYdB;                       %calculo de dJdB
		dJTdB = dJTdB + dJdB;                    %gradiente total
		% atualizacoes
		Yold(2:end) = Yold(1:end-1);
		Yold(1:rede.L:(ns-1)*rede.L+1) = Y;
		dYdCold(2:end,:) = dYdCold(1:end-1,:);
		dYdCold(1:rede.L:(ns-1)*rede.L+1,:) = dYdC;
		dYdAold(2:end,:) = dYdAold(1:end-1,:);
		dYdAold(1:rede.L:(ns-1)*rede.L+1,:) = dYdA;
		dYdBold(2:end,:) = dYdBold(1:end-1,:);
		dYdBold(1:rede.L:(ns-1)*rede.L+1,:) = dYdB;
	end
	
	dJdA = reshape(dJTdA,(ns*rede.L),rede.h)'/N;
	dJdB = reshape(dJTdB,ne+1,rede.h)'/N;
	dJdC = reshape(dJTdC,rede.h+1,ns)'/N;
	EQM = 1/N*sum(sum(vetErro.*vetErro))/N;
end