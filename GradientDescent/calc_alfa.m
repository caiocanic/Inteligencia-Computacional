%Dúvida: O que é a e b? Está certo do jeito implementado?
%Pedir código do professor.

function alfa=calc_alfa(X,d)
	r=(-1+sqrt(5))/2;
	a = 0;
	b = rand;
	
	%Checa se b torna hLinha positivo. Caso não, drobra o valor de b e
	%repete a checagem.
	Xn = X + b*d;
	[~,g,~] = calc_func(Xn);
	hLinha = g'*d;
	while hLinha <=0
		b = 2*b;
		Xn = X + b*d;
		[~,g,~] = calc_func(Xn);
		hLinha = g'*d;
	end
	
	alfa1 = b - r*(b-a);
	alfa2 = a + r*(b-a);
	
	while (alfa2-alfa1)/2 > 1.0e-6
		X1 = X + alfa1*d;
		[~,g,~] = calc_func(X1);
		hLinhaX1 = g'*d;
		X2 = X + alfa2*d;
		[~,g,~] = calc_func(X2);
		hLinhaX2 = g'*d;
		%fprintf("a: %2.5f b: %2.5f  alfa1: %2.5f alfa2: %2.5f hLX1: %2.5f hLX2: %2.5f\n",a,b,alfa1,alfa2,hLinhaX1,hLinhaX2);
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
	fprintf('alfa = %2.7f\n', alfa);
end