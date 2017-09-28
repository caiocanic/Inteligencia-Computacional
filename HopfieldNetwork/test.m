function [resultSyncLetter, resultAsyncLetter, resultSyncNumber, resultAsyncNumber] = test()
	load letras.dat;
	load numeros.dat;
	noisePercentages = [0 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50];
	numTests=100;

	%Testes do conjunto letras.dat
	[K,N]=size(letras);
	res = [20 20];
	label = ["A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L"];
	
	%1)Teste sincrono
	fprintf('Testando atualização sincrona\n');
	resultSyncLetter = test_hopfield(letras, noisePercentages, numTests, "synchronous", "tanh", K, N, res, label);
	
	%2)Teste assincrono
	fprintf('Testando atualização assincrona\n');
	resultAsyncLetter = test_hopfield(letras, noisePercentages, numTests, "asynchronous", "tanh", K, N, res, label);
	
	%Testes do conjunto numeros.dat
	[K,N]=size(numeros);
	res = [5 7];
	label = ["1" "2" "3" "4" "5" "6" "7" "8" "9" "0"];
	
	%1)Teste sincrono
	fprintf('Testando atualização sincrona\n');
	resultSyncNumber = test_hopfield(numeros, noisePercentages, numTests, "synchronous", "tanh", K, N, res, label);
	
	%2)Teste assincrono
	fprintf('Testando atualização assincrona\n');
	resultAsyncNumber = test_hopfield(numeros, noisePercentages, numTests, "asynchronous", "tanh", K, N, res, label);
end

function result=test_hopfield(figures, noisePercentages, numTests, typeTest, typeActivation, K, N,res,label)
	result=zeros(K,length(noisePercentages));
	for i=1:length(noisePercentages)	
		iterator=1;
		while iterator<=numTests
			fprintf('Teste %d\n', iterator)
			fprintf('Ruído: %2.2f\n', noisePercentages(i)); 
			figuresNoise = add_noise(noisePercentages(i), figures, K, N);
			result(:,i) = result(:,i) + hopfield(figures,figuresNoise, label, res, typeTest, typeActivation, K, N)';
			iterator = iterator+1;
		end
	end
end