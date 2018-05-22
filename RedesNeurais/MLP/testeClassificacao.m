%{
Função responsável por chamar a rotina de testes da MLP ou realizar apenas
um treinamento e teste para os dados parâmetros
%}
function testeClassificacao()
	hMax=8;
	nepMax=5000;
	alfaInicial=0.1;
	nroTestes = 10;
	porcValidacao = 0.3;
	func = ["sigmoid","linear";
			"tangente","linear";
			"sigmoid","tangente";
			"tangente","sigmoid";
			"sigmoid","softmax";
			"tangente","softmax"];

	testaMLP(hMax,nepMax,alfaInicial,nroTestes,func,porcValidacao)
end

function testaMLP(hMax,nepMax,alfaInicial,nroTestes,func,porcValidacao)
	treinamento = load("Classificação/iris_treinamento.txt");
	teste = load("Classificação/iris_teste.txt");
	mediaAcerto = zeros(size(func,1),hMax-1);
	acerto = zeros(nroTestes,1);
	
	for i=1:size(func,1)
		fprintf("funcA: %s funcB: %s\n",func(i,1),func(i,2));
		funcA = func(i,1);
		funcB = func(i,2);
		[Xtr,Ydtr,Xvl,Ydvl,Xts,Ydts] = processaClassificacao(treinamento,teste,porcValidacao,func(i,:));
		for h=2:hMax
			fprintf("h: %d\n",h);
			parfor n=1:nroTestes
				fprintf("teste: %d\n",n);
				mlp = Mlp(funcA,funcB,h,nepMax,alfaInicial);
				mlp.treinamento(Xtr,Ydtr,Xvl,Ydvl);
				mlp.teste(Xts);
				acerto(n,1) = traduzClasse(mlp.Y,Ydts);
			end
			mediaAcerto(i,h-1) = mean(acerto);
			save("mediaAcerto.mat","mediaAcerto");
		end
	end
end


%Traduz a saída da classificação de binária para real
function acerto = traduzClasse(Y,Ydts)
	N = length(Y);
	correto = 0;
	[~,I] = max(Y,[],2);
	[~,Id] = max(Ydts,[],2);
	for i=1:N
		if (I(i) == Id(i))
			correto = correto+1;
		end
	end
	acerto = correto/N;
end