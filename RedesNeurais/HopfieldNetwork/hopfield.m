%{
Função que realiza o treinamento da rede de Hopfield em um único passo (W).
Após isso ela faz uma chamada para a etápa de recuperação de padrão
síncrona ou assíncrona dependendo do parámetro typeTest.
Parámetros
figures: conjunto de imagens que terão seus padrões armazenados na rede de
Hopfield;
figuresNoise: versão modificada do conjunto de imagens através da adição
de ruído. Será utilizado para testar a capacidade de recuperação da rede;
label: nome de cada imagem do conjunto de imagens;
res: resolução das imagens do conjunto de imagem;
typeTest: tipo de atualização de estado. Opçoes: synchronous ou asynchronous;
typeActivation: função de ativação que sera usada na etapa de recuperação.
Opções: sign ou tanh;
K: número de imagens no conjunto de imagens;
N: número de pixels das imagens;
%}
function result=hopfield(figures, figuresNoise, label, res, typeTest, typeActivation, K, N)
	P = figures';
	W = P*(inv(P'*P))*P';
	
	if typeTest == "synchronous"
		result = test_synchronous(P, figuresNoise', label, typeActivation, res, W, K);
	elseif typeTest == "asynchronous"
		result = test_asynchronous(P, figuresNoise', label, typeActivation, res, W, K, N);
	end
end

%{
Função auxiliar que realiza a recuperação de padrões com atualização de estado 
da rede de forma síncrona.
Parámetros
P: transposta do conjunto de imagens armazenados na rede;
Pn: tranpsota do conjunto de imagens com ruído;
label: nome de cada imagem do conjunto de imagens;
typeActivation: função de ativação usada para a recuperação. Opções: sign ou tanh;
res: resolução das imagens do conjunto de imagem;
W: Matriz de treinamento da rede;
K: número de imagens no conjunto de imagens;
%}
function result=test_synchronous(P, Pn, label, typeActivation, res, W, K)
	result=zeros(1,K);
	fprintf('Sincrono\n');
	if typeActivation == "sign"
		fprintf('Ativação sign\n');
		calcYnew=@(X)sign(X);
		e=0;
	elseif typeActivation == "tanh"
		fprintf('Ativação tanh\n');
		calcYnew=@(X)tanh(X);
		e=1.0e-2;
	end
	
	for i=1:K
		Yant = Pn(:,i);
		Ynew = calcYnew(W*Yant);
		cont = 1;
		while norm(Yant-Ynew)> e
			cont = cont+1;
			Yant = Ynew;
			Ynew = calcYnew(W*Yant);
		end
		fprintf('Figura: %s Passos %d\n',label(i),cont);
		%plot_figures(sign(Ynew'),1,res(1),res(2));
		if sign(Ynew) == P(:,i)
			result(i)=1;
		end
	end
end

%{
Função auxiliar que realiza a recuperação de padrões com atualização de
estado da rede de forma asssíncrona.
Parámetros
P: transposta do conjunto de imagens armazenados na rede;
Pn: tranpsota do conjunto de imagens com ruído;
label: nome de cada imagem do conjunto de imagens;
typeActivation: função de ativação usada para a recuperação. Opções: sign ou tanh;
res: resolução das imagens do conjunto de imagem;
W: Matriz de treinamento da rede;
K: número de imagens no conjunto de imagens;
N: número de pixels das imagens;
%}
function result=test_asynchronous(P, Pn, label, typeActivation, res, W, K, N)
	result=zeros(1,K);
	fprintf('Assincrono\n');
	if typeActivation == "sign"
		fprintf('Ativação sign\n');
		calcYaux=@(X)sign(X);
		e=0;
	elseif typeActivation == "tanh"
		fprintf('Ativação tanh\n');
		calcYaux=@(X)tanh(X);
		e=1.0e-2;
	end
	
	for i=1:K
		Yant = Pn(:,i);
		pos = ceil(rand(1,1)*N);
		Ynew = Yant;
		Yaux = calcYaux(W*Yant);
		Ynew(pos)=Yaux(pos);
		cont =1;
		while norm(Yant-Yaux)>e
			cont = cont+1;
			pos = ceil(rand(1,1)*N);
			Yant = Ynew;
			Yaux = calcYaux(W*Yant);
			Ynew(pos)=Yaux(pos);
		end
		fprintf('Figura: %s Passos %d\n',label(i),cont);
		%plot_figures(Ynew',1,res(1),res(2));
		if sign(Ynew) == P(:,i)
			result(i)=1;
		end
	end
end