function [X,nroIteracoes]=gradiente(X,alphaMethod)
	nroIteracoes=0;
	%alfa = 0.5;
	[~,g,~] = calc_func(X);
	
	while norm(g)>1.0e-6
		d = -g;
		alfa = calc_alfa(X,d,alphaMethod);
		X = X + alfa*d;
		[~,g,~] = calc_func(X);
		nroIteracoes=nroIteracoes+1;
		fprintf('iteração: %d X(1)=%2.7f X(2)=%2.7f normG = %2.7f\n',nroIteracoes,X(1),X(2),norm(g));
	end
end