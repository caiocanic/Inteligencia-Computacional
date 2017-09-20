%Recebe uma matriz contendo K figuras, insere uma porcetagem de ruído em cada figura e 
%retorna a matriz de figuras com ruído.
%Parámetros
%noisePercentage: porcentagem de ruído desejado;
%figures: matriz KxN de figuras;
%K: Número de figuras na matriz;
%N: Número de pixels nas imagens;

function figuresNoise=add_noise(noisePercentage, figures, K, N)
	figuresNoise = figures;
	
	for i=1:K
		for j=1:N
			r = rand;
			if r<noisePercentage
			   figuresNoise(i,j)= -figuresNoise(i,j);
			end
		end
	end
end