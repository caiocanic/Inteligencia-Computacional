classdef Alfa < handle
	properties (SetAccess = private)
		valor;
	end
	methods
		function alfa = Alfa(valor)
			alfa.valor = valor;
		end
	end
	
	methods
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
			%fprintf("alfa: %2.5f\n",alfa);
		end
		
		function alfa=golden(A,B,dJdA,dJdB,X,Yd,N)
			r=(-1+sqrt(5))/2;
			a = 0;
			b = rand;
			%Checa se b torna hLinha positivo. Caso não, drobra o valor de b e
			%repete a checagem.
			hLinha = calcHLinha(b,A,B,dJdA,dJdB,X,Yd,N);
			while hLinha <=0
				b = 2*b;
				hLinha = calcHLinha(b,A,B,dJdA,dJdB,X,Yd,N);
			end
			alfa1 = b - r*(b-a);
			alfa2 = a + r*(b-a);
			while (alfa2-alfa1)/2 > 1.0e-4
				fprintf("alfa1: %2.5f alfa2: %2.5f alfaM: %2.5f\n",alfa1,alfa2,(alfa1+alfa2)/2);
				hLinhaX1 = calcHLinha(alfa1,A,B,dJdA,dJdB,X,Yd,N);
				hLinhaX2 = calcHLinha(alfa2,A,B,dJdA,dJdB,X,Yd,N);
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
			alfa = (alfa1 + alfa2)/2;
		end
		
		function angulo(alfa,dJdAOld,dJdBOld,mlp)
			EOld = [dJdAOld(:)' dJdBOld(:)'];
			ENew = [mlp.dJdA(:)' mlp.dJdB(:)'];
			cosTeta = ENew*EOld'/(norm(ENew)*norm(EOld));
			alfa.valor = alfa.valor*(exp(1)^(0.1*cosTeta));
			if alfa.valor >= 1
				alfa.valor = mlp.alfa.valor*0.9;
			end
			%fprintf("alfa: %2.5f\n",alfa);
		end
	end
	
	methods (Static = true, Access = private)
		function hLinha = calcHLinha(alfaTest,mlp,X,Yd,N)
			ANew = mlp.A - alfaTest*mlp.dJdA;
			BNew = mlp.B - alfaTest*mlp.dJdB;
			[dJdALinha,dJdBLinha] = calcGrad(X,Yd,ANew,BNew,N);
			d = -[mlp.dJdA(:);mlp.dJdB(:)];
			g = [dJdALinha(:);dJdBLinha(:)];
			hLinha = g'*d;
		end
	end
end