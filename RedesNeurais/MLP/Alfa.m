%{
Classe responsável pelo objeto encarregado do cálculo da taxa de
aprendizagem
Atributos
valor: valor da taxa de aprendizagem;
%}
classdef Alfa < handle
	properties (SetAccess = private)
		valor;
	end
	methods
		%{
		Método construtor
		Parâmetros
		alfaInicial: valor inicial da taxa de aprendizagem;
		Saídas
		alfa: Objeto do tipo Alfa com o atríbuto valor configurado de
		acordo com os parâmetros passados ao método construtor;
		%}
		function alfa = Alfa(alfaInicial)
			alfa.valor = alfaInicial;
		end
		
		%{
		Método responsável por calcular o valor da taxa de aprendizagem
		atravês do método da bisseção.
		Parâmentros
		alfa: objeto do tipo Alfa que terá seu valor atualizado;
		mlp: objeto do tipo Mlp referente a rede para qual o alfa será cálculado;
		X: Conjunto de dados de entrada;
		Yd: Saída desejada para o conjunto de dados X;
		N: Número de instâncias no conjunto de dados X;
		%}
		function bissecao(alfa,mlp,X,Yd,N)
			a = 0;
			b = rand;
			%Checa se b torna hLinha positivo. Caso não, drobra o valor de b e
			%repete a checagem.
			hLinha = Alfa.calcHLinha(b,mlp,X,Yd,N);
			while hLinha <= 0
				b = 2*b;
				hLinha = Alfa.calcHLinha(b,mlp,X,Yd,N);
			end
			alfaM=(a+b)/2;
			hLinha = Alfa.calcHLinha(alfaM,mlp,X,Yd,N);
			while abs(hLinha) > 1.0e-4
				%fprintf("a: %2.5f b: %2.5f alfaM: %2.5f\n",a,b,alfaM);
				if hLinha > 0
					b=alfaM;
				else
					a=alfaM;
				end
				alfaM=(a+b)/2;
				hLinha = Alfa.calcHLinha(alfaM,mlp,X,Yd,N);
			end
			alfa.valor=alfaM;
			%fprintf("alfa: %2.5f\n",alfa.valor);
		end

		%{
		Método responsável por calcular o valor da taxa de aprendizagem
		atravês do método da seção aurea.
		Parâmentros
		alfa: objeto do tipo Alfa que terá seu valor atualizado;
		mlp: objeto do tipo Mlp referente a rede para qual o alfa será cálculado;
		X: Conjunto de dados de entrada;
		Yd: Saída desejada para o conjunto de dados X;
		N: Número de instâncias no conjunto de dados X;
		%}
		function golden(alfa,mlp,X,Yd,N)
			r=(-1+sqrt(5))/2;
			a = 0;
			b = rand;
			%Checa se b torna hLinha positivo. Caso não, drobra o valor de b e
			%repete a checagem.
			hLinha = Alfa.calcHLinha(b,mlp,X,Yd,N);
			while hLinha <=0
				b = b*2;
				hLinha = Alfa.calcHLinha(b,mlp,X,Yd,N);
			end
			alfa1 = b - r*(b-a);
			alfa2 = a + r*(b-a);
			while (alfa2-alfa1)/2 > 1.0e-4
				%fprintf("alfa1: %2.5f alfa2: %2.5f alfaM: %2.5f\n",alfa1,alfa2,(alfa1+alfa2)/2);
				hLinhaX1 = Alfa.calcHLinha(alfa1,mlp,X,Yd,N);
				hLinhaX2 = Alfa.calcHLinha(alfa2,mlp,X,Yd,N);
				if hLinhaX1*hLinhaX2 < 0
					b = alfa2;
					alfa2 = alfa1;
					alfa1 = b - r*(b-a);
				else
					if hLinhaX1 > 0
						b = alfa2;
						alfa2 = alfa1;
						alfa1 = b - r*(b-a);
					else
						a = alfa1;
						alfa1 = alfa2;
						alfa2 = a + r*(b-a);
					end
				end
			end
			alfa.valor = (alfa1 + alfa2)/2;
		end

		%{
		Método responsável por cálcular o alfa com base no angulo entre o
		gradiente atual e o gradiente da iteração passada.
		Parâmetros
		alfa: Objeto do tipo Alfa que terá seu valor atualizado;
		dJdAOld: Gradiente da matriz A na iteração anterior;
		dJdBOld: Gradiente da matriz B na iteração anterior;
		mlp: objeto do tipo Mlp referente a rede para qual o alfa está
		sendo cálculado;
		%}
		function angulo(alfa,dJdAOld,dJdBOld,mlp)
			EOld = [reshape(dJdAOld',1,numel(dJdAOld)) reshape(dJdBOld',1,numel(dJdBOld))];
			ENew = [reshape(mlp.dJdA',1,numel(mlp.dJdA)) reshape(mlp.dJdB',1,numel(mlp.dJdB))];
			cosTeta = ENew*EOld'/(norm(ENew)*norm(EOld));
			alfa.valor = alfa.valor*(exp(1)^(0.1*cosTeta));
			if alfa.valor >= 1
				alfa.valor = mlp.alfa.valor*0.9;
			end
			%fprintf("alfa: %2.5f\n",alfa.valor);
		end
	end
	methods (Static = true, Access = private)
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
		function hLinha = calcHLinha(alfaTest,mlp,X,Yd,N)
			ANew = mlp.A - alfaTest*mlp.dJdA;
			BNew = mlp.B - alfaTest*mlp.dJdB;
			[dJdALinha,dJdBLinha] = calcGrad(X,Yd,ANew,BNew,N);
			%d = [mlp.dJdA(:); mlp.dJdB(:)];
			%g = [dJdALinha(:); dJdBLinha(:)];
			d = -[reshape(mlp.dJdA',1,numel(mlp.dJdA))'; reshape(mlp.dJdB',1,numel(mlp.dJdB))'];
			g = [reshape(dJdALinha',1,numel(dJdALinha))'; reshape(dJdBLinha',1,numel(dJdBLinha))'];
			hLinha = g'*d;
		end
	end
end