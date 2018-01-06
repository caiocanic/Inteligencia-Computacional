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
				for j=1:size(novaPopulacao,2)
					r = rand;
					if r <= genetico.pMutacao
						p = round(intervalo(1) + (intervalo(2)-intervalo(1)).*rand);
						temp = novaPopulacao(i,p);
						novaPopulacao(i,p) = novaPopulacao(i,j);
						novaPopulacao(i,j) = temp;
					end
				end
			end
		end
		
		%Mutação reversiva
		function novaPopulacao = reversiva(genetico,populacaoInicial)
			novaPopulacao = populacaoInicial;
			for i=1:size(novaPopulacao,1)
				for j=1:size(novaPopulacao,2)
					r = rand;
					if r <= genetico.pMutacao
						if j-1>=1
							novaPopulacao(i,j-1) = ~novaPopulacao(i,j-1);
						end
						if j+1<=size(novaPopulacao,2)
							novaPopulacao(i,j+1) = ~novaPopulacao(i,j+1);
						end
					end
				end
			end
		end
	end
end