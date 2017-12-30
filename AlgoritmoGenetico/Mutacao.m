classdef Mutacao
	methods (Static = true)
		%Mutação pontual
		function novaPopulacao = pontual(genetico,populacaoInicial)
			novaPopulacao = populacaoInicial;
			for i=1:size(novaPopulacao,1)
				for j=1:size(novaPopulacao,2)
					r = rand;
					if r <= genetico.pMutacao
						novaPopulacao(i,j) = ~novaPopulacao(i,j);
					end
				end
			end
		end
		
		%Mutação por troca
		function novaPopulacao = troca(genetico,populacaoInicial)
			intervalo = [1,size(genetico.populacao.matriz,2)];
			novaPopulacao = populacaoInicial;
			for i=1:size(novaPopulacao,1)
				r = rand;
				if r <= genetico.pMutacao
					p1 = round(intervalo(1) + (intervalo(2)-intervalo(1)).*rand);
					p2 = round(intervalo(1) + (intervalo(2)-intervalo(1)).*rand);
					temp = novaPopulacao(i,p1);
					novaPopulacao(i,p1) = novaPopulacao(i,p2);
					novaPopulacao(i,p2) = temp;
				end
			end
		end
	end
	
end