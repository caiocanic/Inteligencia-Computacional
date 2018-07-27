classdef ProcessaDados
	methods (Static = true)
		%Função responsável por achar os número de lags da entrada.
		function lag = achaLag(dados,lagMax)
			%Determina os lags possiveis por meio da correlação
			coef = zeros(lagMax,1);
			for i=1:lagMax
				%Calcula a correlação de x(i) com x(i+1)
				temp = corrcoef(dados(i:end-1),dados(i+1:end)); 
				coef(i,1) = temp(1,2);
			end
			%Deixa em modulo pois interessa a menor correlação, positiva ou
			%negativa
			coef = abs(coef);
			%Acha a menor correlação, será o lag utilizado
			[~,lag] = min(coef);
		end
		
		function dadosLag = adicionaLag(dados,lag)
			
		end
		
		%Função responsável por separar os dados em k partições para a
		%validação cruzada
		function kFolds = geraKFolds(dados,k)
			%Inicializa as partições vazias
			kFolds = cell(1,10);
			%Arredonda para baixo, para que as partições tenham sempre o
			%mesmo tamanho, alguns dados são descartados.
			tamanho = round(size(dados,1)/k,-1);
			%Embaralha os dados
			dados = dados(randperm(size(dados,1)),:);
			%Gera as partições
			for i=1:k
				kFolds{i} = dados(1+((i-1)*tamanho):tamanho*i);
			end
		end
		
		%Função responsável por normalizar dados
		function dadosNorm = normaliza(dados)
			dadosNorm = (dados-mean(dados))/std(dados);
		end
	end
end