function [meanValue,contadores]=test_gradient()
	i=1;
	nroTestes=1;
	contadores=zeros(nroTestes,1);

	while i <= nroTestes
		X = -10 + (10+10).*rand(2,1);
		[~,nroIteracoes] = gradiente(X,"golden");
		contadores(i)=nroIteracoes;
		i=i+1;
	end
	meanValue=mean(contadores);
end