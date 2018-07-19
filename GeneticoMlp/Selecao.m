classdef Selecao
	methods (Static = true)
		%Seleção via roleta
		function selecionados = roleta(genetico,nroSorteios)
			%Normaliza o fitness
			a=1;
			b=100;
			fitnessNorm =a+((genetico.fitness.matriz-min(genetico.fitness.matriz))*(b-a))/(max((genetico.fitness.matriz))-min(genetico.fitness.matriz));
			%Gera os intervalos da roleta.
			porcentagensRoleta = fitnessNorm/sum(fitnessNorm);
			intervalosRoleta = zeros(genetico.populacao.tamanho,2);
			intervalosRoleta(1,1) = 0;
			intervalosRoleta(1,2) = porcentagensRoleta(1);
			for i=1:genetico.populacao.tamanho-1
				intervalosRoleta(i+1,1) = sum(porcentagensRoleta(1:i));
				intervalosRoleta(i+1,2) = sum(porcentagensRoleta(1:i+1));
			end
			selecionados = zeros(nroSorteios,1);
			%Sorteia os indivíduos
			for i=1:nroSorteios
				r = rand;
				%Sorteia indivíduo
				for j=1:genetico.populacao.tamanho
					if r >= intervalosRoleta(j,1) && r < intervalosRoleta(j,2)
						selecionados(i,1) = j;
						break;
					end
				end
			end
		end
		
		%Seleção bi-classista.
		function selecionados = classista(genetico,nroSorteios,b,w)
			minR=1;
			maxR=genetico.populacao.tamanho;
			qtdMelhores=ceil(b*nroSorteios);
			qtdPiores=floor(w*nroSorteios);
			qtdDemais = nroSorteios-qtdMelhores-qtdPiores;
			melhores = (genetico.populacao.tamanho-qtdMelhores+1:genetico.populacao.tamanho)';
			piores = (1:qtdPiores)';
			demais = zeros(qtdDemais,1);
			for i=1:qtdDemais
				r = minR + (maxR-minR).*rand;
				demais(i,1) = ceil(r);
			end
			selecionados = [melhores;demais;piores];
		end
		
		%Seleção por torneio
		function selecionados = torneio(genetico,nroSorteios)
			selecionados = zeros(nroSorteios);
			%Define o número de "combates"
			q=10;
			a = 1;
			b = genetico.populacao.tamanho;
			vitorias = zeros(genetico.populacao.tamanho,2);
			vitorias(:,2) = 1:genetico.populacao.tamanho;
			for i=1:genetico.populacao.tamanho
				for j=1:q
					r = round(a + (b-a).*rand);
					if genetico.fitness.matriz(i) > genetico.fitness.matriz(r)
						vitorias(i,1) = vitorias(i,1)+1;
					end
				end
			end
			%Ordena a matriz de vitórias
			vitorias = sortrows(vitorias,1);
			for i=1:nroSorteios
				selecionados(i) = vitorias(i,2);
			end
		end
	end
end