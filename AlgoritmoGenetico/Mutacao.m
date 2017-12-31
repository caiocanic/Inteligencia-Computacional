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
		
		%Mutação por soma de um valor pequeno
		function novaPopulacao = soma(genetico,populacaoInicial)
			a =0;
			b = 0.1;
			novaPopulacao = populacaoInicial;
			for i=1:size(novaPopulacao,1)
				for j=1:genetico.populacao.nroBits
					r = rand;
					%Checa se havera mutação
					if r <= genetico.pMutacao
						n = a + (b-a).*rand;
						novaPopulacao(i,j) = novaPopulacao(i,j)+n;
					end
				end
			end
		end
		
		%Mutação por multiplicação
		function novaPopulacao = multiplicacao(genetico,populacaoInicial)
			a =0.9;
			b = 1.1;
			novaPopulacao = populacaoInicial;
			for i=1:size(novaPopulacao,1)
				for j=1:genetico.populacao.nroBits
					r = rand;
					%Checa se havera mutação
					if r <= genetico.pMutacao
						n = a + (b-a).*rand;
						novaPopulacao(i,j) = novaPopulacao(i,j)*n;
					end
				end
			end
		end
		
		%Mutação aleatória
		function novaPopulacao = aleatoria(genetico,populacaoInicial)
			novaPopulacao = populacaoInicial;
			for i=1:size(novaPopulacao,1)
				for j=1:genetico.populacao.nroBits
					r = rand;
					%Checa se havera mutação
					if r <= genetico.pMutacao
						a =genetico.funcao.intervaloBusca(j,1);
						b =genetico.funcao.intervaloBusca(j,1);
						n = a + (b-a).*rand;
						novaPopulacao(i,j) = n;
					end
				end
			end
		end
	end
	
end