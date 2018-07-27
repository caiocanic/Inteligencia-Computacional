%{
Classe responsável pelo objeto que representa uma Multilayer Perceptron.
Atributos
h: Número de neurónios da rede;
nepMax: Número máximo de épocas para a condição de parada;
nepConvergencia: Época em que a rede convergiu;
alfa: taxa de aprendizagem;
A: Matriz de pesos das entradas;
funcA: Função de ativação da camada oculta;
B: Matriz de pesos da camada de saída;
funcB: Função de ativação da camada de saída;
dJdA: Gradiente da matriz A;
dJdB: Gradiente da matriz B;
Y: Saída fornecida pela rede;
%}
classdef Mlp < handle
	properties (SetAccess = private)
		h;
		nepMax;
		nepConvergencia;
		alfa;
		A;
		funcA;
		B;
		funcB;
		dJdA;
		dJdB;
		Y;
	end
	methods
		%{
		Método contrutor
		Parâmetros
		funcA: Função de ativação da camada oculta;
		funcB: Função de ativação da camada de saída;
		h: Número de neurónios da rede;
		nepMax: Número máximo de épocas para a condição de parada;
		alfaInicial: Valor inicial da taxa de aprendizagem;
		Saída
		mlp: Objeto do tipo Mlp com os atribútos equivalentes aos parâmetros
		passados ao construtor;
		%}
		function mlp = Mlp(funcA,funcB,h,nepMax,alfaInicial)
			mlp.funcA = funcA;
			mlp.funcB = funcB;
			mlp.h = h;
			mlp.nepMax = nepMax;
			mlp.alfa = alfaInicial;
			mlp.A = [];
			mlp.B = [];
		end
		
		%{
		Função para inicializar a matriz de pesos com tamanho específico.
		(Usado na mistura de especialistas)
		Parâmetros
		sizeA: Vetor 1x2 em que sizeA(1) representa a primeira dimensão de
		A e sizeA(2) representa a segunda dimensão
		sizeB: Mesmo que sizeA, porém para matriz de pesos B
		%}
		function inicializaPesos(mlp,sizeA,sizeB)
			%Inicializa as matrizes de pesos A e B
			a = -0.2;
			b = 0.2;
			mlp.A = a + (b-a).*rand(sizeA(1),sizeA(2)+1);
			mlp.B = a + (b-a).*rand(sizeB(1),sizeB(2)+1);
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
		Ygd: Probabilidade a posteriori do EM (Usado na mistura de
		especialista);
		%}
		function treinamento(mlp,Xtr,Ydtr,Xvl,Ydvl,nVlMax,Ygd)
			%Determina o n. de instâncias, entradas e saídas
			[Ntr,netr] = size(Xtr);
			[Nvl,~] = size(Xvl);
			ns = size(Ydtr,2);
			%Adiciona o bias
			Xtr = [Xtr, ones(Ntr,1)];
			Xvl = [Xvl, ones(Nvl,1)];
			%Inicializa as matrizes de pesos A e B
			if isempty(mlp.A) && isempty(mlp.B)
				a = -0.2;
				b = 0.2;
				mlp.A = a + (b-a).*rand(mlp.h,netr+1);
				mlp.B = a + (b-a).*rand(ns,mlp.h+1);
			end
			%Inicia Treinamento
			nep=1;
			nVl = 0;
			[mlp.dJdA, mlp.dJdB] = mlp.calcGrad(Xtr,Ydtr,mlp.A,mlp.funcA,mlp.B,mlp.funcB,Ntr,mlp.h,Ygd);
			mlp.Y = mlp.calcSaida(mlp.A,mlp.funcA,mlp.B,mlp.funcB,Xtr,Ntr);
			errotr = mlp.Y-Ydtr;
			EQMtr(nep) = 1/Ntr*sum(sum(errotr.*errotr));
			%Checa se haverá validação
			if ~isempty(Xvl) && ~isempty(Ydvl)
				%Inicia Validação
				Yvl = mlp.calcSaida(mlp.A,mlp.funcA,mlp.B,mlp.funcB,Xvl,Nvl);
				errovl = Yvl-Ydvl;
				EQMvl(nep) = 1/Nvl*sum(sum(errovl.*errovl));
				EQMvlBest = EQMvl(nep);
			end
			%Treina e valida até que atinga a condição de parada.
			%Condição 1: Erro mínimo
			%Condição 2: número máximo de época de treinamento
			%Condição 3: Número de validação sem melhorar o resultado
			while EQMtr(nep) > 1.0e-6 && nep < mlp.nepMax && nVl < nVlMax
				nep = nep+1;
				%Cálcula o alfa pela bissecao
				mlp.calcAlfa(Xtr,Ydtr,Ntr,Ygd);
				%Atualiza os pesos
				Anew = mlp.A - mlp.alfa*mlp.dJdA;
				Bnew = mlp.B - mlp.alfa*mlp.dJdB;
				%Checa se haverá validação
				if ~isempty(Xvl) && ~isempty(Ydvl)
					%Validação
					Yvl = mlp.calcSaida(Anew,mlp.funcA,Bnew,mlp.funcB,Xvl,Nvl);
					errovl = Yvl-Ydvl;
					EQMvl(nep) = 1/Ntr*sum(sum(errovl.*errovl));
					if EQMvl(nep) < EQMvlBest
						ABest = mlp.A;
						BBest = mlp.B;
						mlp.nepConvergencia = nep;
						EQMvlBest = EQMvl(nep);
						nVl = 0;
					else
						nVl = nVl + 1;
					end
				end
				mlp.A = Anew;
				mlp.B = Bnew;
				%Recálcula o gradiente
				[mlp.dJdA, mlp.dJdB] = mlp.calcGrad(Xtr,Ydtr,mlp.A,mlp.funcA,mlp.B,mlp.funcB,Ntr,mlp.h,Ygd);
				%Cálcula o erro
				mlp.Y = mlp.calcSaida(mlp.A,mlp.funcA,mlp.B,mlp.funcB,Xtr,Ntr);
				errotr = mlp.Y-Ydtr;
				EQMtr(nep) = 1/Ntr*sum(sum(errotr.*errotr));
				%fprintf("EQMtr: %f\n",EQMtr(nep));
			end
			%Checa se houve validação
			if ~isempty(Xvl) && ~isempty(Ydvl)
				mlp.A = ABest;
				mlp.B = BBest;
			else
				mlp.nepConvergencia = nep;
			end
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
			[Nts,~] = size(Xts);
			%Adiciona o bias
			Xts(:,end+1) = 1;
			%Calcula a saída
			mlp.Y = mlp.calcSaida(mlp.A,mlp.funcA,mlp.B,mlp.funcB,Xts,Nts);
		end
	end
	
	methods (Access = private)
		%{
		Método responsável por calcular o valor da taxa de aprendizagem
		atravês do método da bisseção.
		Parâmentros
		mlp: objeto do tipo Mlp referente a rede para qual o alfa será cálculado;
		X: Conjunto de dados de entrada;
		Yd: Saída desejada para o conjunto de dados X;
		N: Número de instâncias no conjunto de dados X;
		%}
		function calcAlfa(mlp,X,Yd,N,Ygd)
			%Parâmetros internos
			a = 0;
			b = rand;
			kMax = 50;
			k=0;
			%Checa se b torna hLinha positivo. Caso não, drobra o valor de b e
			%repete a checagem.
			hLinha = mlp.calcHLinha(b,X,Yd,N,Ygd);
			while hLinha <= 0
				b = 2*b;
				hLinha = mlp.calcHLinha(b,X,Yd,N,Ygd);
			end
			alfaM=(a+b)/2;
			hLinha = mlp.calcHLinha(alfaM,X,Yd,N,Ygd);
			while abs(hLinha) > 1.0e-4 && k <= kMax
				k = k+1;
				%fprintf("a: %2.5f b: %2.5f alfaM: %2.5f\n",a,b,alfaM);
				if hLinha > 0
					b=alfaM;
				else
					a=alfaM;
				end
				alfaM=(a+b)/2;
				hLinha = mlp.calcHLinha(alfaM,X,Yd,N,Ygd);
			end
			if alfaM <=1.0e-5
				alfaM = 1.0e-5;
			end
			mlp.alfa = alfaM;
			%fprintf("alfa: %2.5f\n",mlp.alfa);
		end
			
		%{
		Função auxiliar para o cálculo do hLinha durante o processo de
		encontrar o alfa ótimo.
		Parâmetros
		alfaTest: taxa de aprendizagem candidata à ótimo;
		mlp: rede para qual o alfa está sendo cálculado;
		X: Conjundo de dados de entrada;
		Yd: Saída esperada para o conjunto X;
		N:Número de instâncias no conjunto de dados X;
		%}
		function hLinha = calcHLinha(mlp,alfaTest,X,Yd,N,Ygd)
			ANew = mlp.A - alfaTest*mlp.dJdA;
			BNew = mlp.B - alfaTest*mlp.dJdB;
			[dJdALinha,dJdBLinha] = mlp.calcGrad(X,Yd,ANew,mlp.funcA,BNew,mlp.funcB,N,mlp.h,Ygd);
			d = -[reshape(mlp.dJdA',1,numel(mlp.dJdA))'; reshape(mlp.dJdB',1,numel(mlp.dJdB))'];
			g = [reshape(dJdALinha',1,numel(dJdALinha))'; reshape(dJdBLinha',1,numel(dJdBLinha))'];
			hLinha = g'*d;
		end
		
	end
	
	methods (Static = true, Access = private)
		%{
		Função auxiliar para o cálculo da saída da rede.
		Parâmetros
		A: Matriz de pesos da entrada;
		funcA: Função de ativação da camada oculta;
		B: Matriz de pesos da camda de saída;
		funcB: Função de ativação da camada de saída;
		X: Conjunto de dados para o qual se deseja calcular a saída da rede;
		N: Número de instâncias no conjunto X;
		Saída
		Y: Saída da rede para o conjunto de dados X dadas as matrizes de 
		pesos A e B;
		%}
		function Y = calcSaida(A,funcA,B,funcB,X,N)
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
		end
		
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
		Ygd: Probabilidade a posteriori do EM (Usado na mistura de
		especialista);
		%}
		function [dJdA, dJdB] = calcGrad(X,Yd,A,funcA,B,funcB,N,h,Ygd)
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
			erro = (Y-Yd).*Ygd;
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