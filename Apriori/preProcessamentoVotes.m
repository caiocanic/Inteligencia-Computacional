%Pré-processamento house-votes-84 com search-replace
%democrat=0, republican=1;
%y=1,n=0,?=abstencoes=-1

%{
1. Class Name: 2 (democrat, republican)
	democrat 1
	republican 2
2. handicapped-infants: 2 (y,n)
	Y 3
	N 4
	? 5
3. water-project-cost-sharing: 2 (y,n)
	Y 6
	N 7
	? 8
4. adoption-of-the-budget-resolution: 2 (y,n)
	Y 9
	N 10
	? 11
...
%}
function transacoes = preProcessamentoVotes()
	dataset = load("datasets/house-votes-84.txt");
	N = size(dataset,1); %número de dados
	ne = size(dataset,2); %número de colunas
	dadosTratados =  zeros(N,size(dataset,2));

	for i=1:N
		if dataset(i,1) == 0
			dadosTratados(i,1) = 1;
		else
			dadosTratados(i,1) = 2;
		end
		k=3;
		for j=2:ne
			if dataset(i,j) == 1
				dadosTratados(i,j) = k;
			elseif dataset(i,j) == 0
				dadosTratados(i,j) = k+1;
			else
				dadosTratados(i,j) = k+2;
			end
			k = k+3;
			disp(k);
		end
	end

	dadosTratados = sortrows(dadosTratados,1);
	transacoes = extraiTransacoes(dadosTratados,N);
	%dlmwrite('treated-house-votes-84.txt',dadosTratados);
end

function transacoes = extraiTransacoes(dadosTratados,N)
	transacoes = struct('itens', cell(1,N));
	for i=1:N
		transacoes(i).itens = dadosTratados(i,:);
	end
end