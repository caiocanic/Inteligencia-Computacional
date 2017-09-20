function alfa=calc_alfa(X,d,type)
	if (type == "golden")
		alfa=golden_section(X,d);
	else
		alfa=bisection(X,d);
	end
	fprintf('alfa = %2.7f\n', alfa);
end

function alfa=golden_section(X,d)
	r=(-1+sqrt(5))/2;
	a = 0;
	b = rand;

	%Checa se b torna hLinha positivo. Caso não, drobra o valor de b e
	%repete a checagem.
	hLinha = calc_hLinha(b,X,d);
	while hLinha <=0
		b = 2*b;
		hLinha = calc_hLinha(b,X,d);
	end
	alfa1 = b - r*(b-a);
	alfa2 = a + r*(b-a);
	
	while (alfa2-alfa1)/2 > 1.0e-4
		hLinhaX1 = calc_hLinha(alfa1,X,d);
		hLinhaX2 = calc_hLinha(alfa2,X,d);
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

function alfa=bisection(X,d)
	a = 0;
	b = rand;
	
	%Checa se b torna hLinha positivo. Caso não, drobra o valor de b e
	%repete a checagem.
	hLinha = calc_hLinha(b,X,d);
	while hLinha <= 0
		b = 2*b;
		hLinha = calc_hLinha(b,X,d);
	end
	alfaM=(a+b)/2;
	hLinhaM = calc_hLinha(alfaM,X,d);
	
	while abs(hLinhaM) > 1.0e-4
		%fprintf("a: %2.5f b: %2.5f alfaM: %2.5f\n",a,b,alfaM);
		pause
		if hLinhaM > 0
			b=alfaM;
		else
			a=alfaM;
		end
		alfaM=(a+b)/2;
		hLinhaM = calc_hLinha(alfaM,X,d);
	end
	alfa=alfaM;
end

function hLinha=calc_hLinha(alpaTest,X,d)
	Xn = X + alpaTest*d;
	[~,g,~] = calc_func(Xn);
	hLinha = g'*d;
end