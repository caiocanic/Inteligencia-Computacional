%{
Classe responsável pelo objeto encarregado do cálculo da taxa de
aprendizagem
Atributos
valor: valor da taxa de aprendizagem;
hLinha: valor da função calcHLinha
%}
classdef Alfa < handle
	properties (SetAccess = private)
		valor;
		hLinha;
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
		rede: objeto do tipo RedeRecorrente referente a rede para qual o alfa será cálculado;
		X: Conjunto de dados de entrada;
		Yd: Saída desejada para o conjunto de dados X;
		N: Número de instâncias no conjunto de dados X;
		ne: Número de entradas externas da rede;
		ns: Número de saídas da rede;
		%}
		function bissecao(alfa,rede,X,Yd,N,ne,ns)
			a = 0;
			b = rand;
			%Checa se b torna hLinha positivo. Caso não, drobra o valor de b e
			%repete a checagem.
			calcHLinha(alfa,b,rede,X,Yd,N,ne,ns);
			while alfa.hLinha <= 0
				b = 2*b;
				calcHLinha(alfa,b,rede,X,Yd,N,ne,ns);
			end
			alfaM=(a+b)/2;
			calcHLinha(alfa,alfaM,rede,X,Yd,N,ne,ns);
			while abs(alfa.hLinha) > 1.0e-4
				disp(alfa.hLinha)
				fprintf("a: %2.5f b: %2.5f alfaM: %2.5f\n",a,b,alfaM);
				pause;
				if alfa.hLinha > 0
					b=alfaM;
				else
					a=alfaM;
				end
				alfaM=(a+b)/2;
				calcHLinha(alfa,alfaM,rede,X,Yd,N,ne,ns);
			end
			alfa.valor=alfaM;
			fprintf("alfa: %2.5f\n",alfa.valor);
		end

		%{
		Método responsável por calcular o valor da taxa de aprendizagem
		atravês do método da seção aurea.
		Parâmentros
		alfa: objeto do tipo Alfa que terá seu valor atualizado;
		rede: objeto do tipo RedeRecorrente referente a rede para qual o alfa será cálculado;
		X: Conjunto de dados de entrada;
		Yd: Saída desejada para o conjunto de dados X;
		N: Número de instâncias no conjunto de dados X;
		ne: Número de entradas externas da rede;
		ns: Número de saídas da rede;
		%}
		function golden(alfa,rede,X,Yd,N,ne,ns)
			r=(-1+sqrt(5))/2;
			a = 0;
			b = rand;
			%Checa se b torna hLinha positivo. Caso não, drobra o valor de b e
			%repete a checagem.
			calcHLinha(alfa,b,rede,X,Yd,N,ne,ns);
			while alfa.hLinha <=0
				b = b*2;
				calcHLinha(alfa,b,rede,X,Yd,N,ne,ns);
			end
			alfa1 = b - r*(b-a);
			alfa2 = a + r*(b-a);
			while (alfa2-alfa1)/2 > 1.0e-4
				fprintf("alfa1: %2.5f alfa2: %2.5f alfaM: %2.5f\n",alfa1,alfa2,(alfa1+alfa2)/2);
				pause;
				calcHLinha(alfa,alfa1,rede,X,Yd,N,ne,ns);
				hLinhaX1 = alfa.hLinha;
				calcHLinha(alfa,alfa2,rede,X,Yd,N,ne,ns);
				hLinhaX2 = alfa.hLinha;
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
		rede: objeto do tipo RedeRecorrente referente a rede para qual o alfa está
		sendo cálculado;
		%}
		function angulo(alfa,rede,dJdAOld,dJdBOld,dJdCOld)
			EOld = -alfa.valor*[reshape(dJdAOld',1,numel(dJdAOld)) reshape(dJdBOld',1,numel(dJdBOld)) reshape(dJdCOld',1,numel(dJdCOld))];
			ENew = [reshape(rede.dJdA',1,numel(rede.dJdA)) reshape(rede.dJdB',1,numel(rede.dJdB)) reshape(rede.dJdC',1,numel(rede.dJdC))];
			cosTeta = -ENew*EOld'/(norm(ENew)*norm(EOld));
			alfa.valor = alfa.valor*(exp(1)^(0.1*cosTeta));
			alfa.valor = alfa.valor/(1+alfa.valor*(sum(ENew.*ENew)));
			%Impoem limites para os valores min e max do alfa
			if alfa.valor < 1.0e-5
				alfa.valor=1.0e-5;
			end
			if alfa.valor > 10
				alfa.valor = 1;
			end
			%fprintf("alfa: %2.5f\n",alfa.valor);
		end
	end
	methods (Access = private)
		%{
		Função auxiliar para o cálculo do hLinha durante o processo de
		encontrar o alfa ótimo.
		Parâmetros
		alfaTest: taxa de aprendizagem candidata à ótimo;
		rede: rede para qual o alfa está sendo cálculado;
		X: Conjundo de dados de entrada;
		Yd: Saída esperada para o conjunto X;
		N:Número de instâncias no conjunto de dados X;
		%}
		function calcHLinha(alfa,alfaTest,rede,X,Yd,N,ne,ns)
			ANew = rede.A - alfaTest*rede.dJdA;
			BNew = rede.B - alfaTest*rede.dJdB;
			CNew = rede.C - alfaTest*rede.dJdC;
			redeNew = rede;
			setPesos(redeNew,ANew,BNew,CNew);
			[dJdALinha, dJdBLinha, dJdCLinha, ~, ~] = calcGrad(redeNew,X,Yd,N,ne,ns);
			d = -[reshape(rede.dJdA',1,numel(rede.dJdA))';reshape(rede.dJdB',1,numel(rede.dJdB))';reshape(rede.dJdC',1,numel(rede.dJdC))'];
			g = [reshape(dJdALinha',1,numel(dJdALinha))';reshape(dJdBLinha',1,numel(dJdBLinha))';reshape(dJdCLinha',1,numel(dJdCLinha))'];
			alfa.hLinha = g'*d;
		end
	end
end