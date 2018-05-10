%Determina o alfa ótimo pelo método da bisseção
function  alfa = calcAlfa(X,Yd,d,A,N,funcao) 
	k = 50; %número máximo de iterações
	alfaL = 0;
	alfaU = rand;
	Aaux = A + alfaU*d;
	dJdA = grad(X,Yd,Aaux,N,funcao);
	hl = dJdA(:)'*d(:);

	%checa se alfa_u torna hl positivo
	while hl<0
		alfaU = 2*alfaU;
		Aaux = A + alfaU*d;
		dJdA = grad(X,Yd,Aaux,N,funcao);
		hl = dJdA(:)'*d(:);
	end
	
	%Se hl==0, já encontrou alfa ideal
	if hl==0
		alfa = alfaU;
		return;
	end
	alfaM = (alfaU+alfaL)/2;
	Aaux = A + alfaM*d;
	dJdA = grad(X,Yd,Aaux,N,funcao);
	hl = dJdA(:)'*d(:);
	
	while abs(hl)>1e-4 && k>0
		if hl>0
			alfaU = alfaM;
		else
			alfaL = alfaM;
		end
		alfaM = (alfaU+alfaL)/2;
		Aaux = A + alfaM*d;
		dJdA = grad(X,Yd,Aaux,N,funcao);
		hl = dJdA(:)'*d(:);
		k = k-1;
	end
	alfa = alfaM;
end