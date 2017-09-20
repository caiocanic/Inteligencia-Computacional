%Função que realiza o treinamento da rede de Hopfield em um único passo (W).
%Após isso ela faz uma chamada para a etápa de recuperação de padrão
%síncrona ou assíncrona dependendo do parámetro type.
%Parámetros
%figures: conjunto de imagens que terão seus padrões armazenados na rede de
%Hopfield;
%figuresNoise: versão modificada do conjunto de imagens através da adição
%de ruído. Será utilizado para testar a capacidade de recuperação da rede;
%label: nome de cada imagem do conjunto de imagens;
%res: resolução das imagens do conjunto de imagem;
%type: tipo de atualização de estado. 0=síncrono e 1=assíncrono;
%K: número de imagens no conjunto de imagens;
%N: número de pixels das imagens;
function result=hopfield(figures, figuresNoise, label, res, type, K, N)
	P = figures';
	W = P*(inv(P'*P))*P';
	
	if type == 0
		result = test_synchronous(P, figuresNoise', label, res, W, K);
	else
		result = test_asynchronous(P, figuresNoise', label, res, W, K, N);
	end
end

%Função auxiliar que realiza a recuperação de padrões com atualização de
%estado da rede de forma síncrona.
%Parámetros
%P: transposta do conjunto de imagens armazenados na rede;
%Pn: tranpsota do conjunto de imagens com ruído;
%label: nome de cada imagem do conjunto de imagens;
%res: resolução das imagens do conjunto de imagem;
%W: Matriz de treinamento da rede;
%K: número de imagens no conjunto de imagens;
function result=test_synchronous(P, Pn, label, res, W, K)
	result=zeros(1,K);
	fprintf('Sincrono\n');
	for i=1:K
		Yant = Pn(:,i);
		Ynew = sign(W*Yant);
		cont =1;
		while norm(Yant-Ynew)>0
			cont = cont+1;
			Yant = Ynew;
			Ynew = sign(W*Yant);
		end
		fprintf('Figura: %s Passos %d\n',label(i),cont);
		%plot_figures(Ynew',1,res(1),res(2));
		if Ynew == P(:,i)
			result(i)=1;
		end
	end
end

%Função auxiliar que realiza a recuperação de padrões com atualização de
%estado da rede de forma asssíncrona.
%Parámetros
%P: transposta do conjunto de imagens armazenados na rede;
%Pn: tranpsota do conjunto de imagens com ruído;
%label: nome de cada imagem do conjunto de imagens;
%res: resolução das imagens do conjunto de imagem;
%W: Matriz de treinamento da rede;
%K: número de imagens no conjunto de imagens;
%N: número de pixels das imagens;
function result=test_asynchronous(P, Pn, label, res, W, K, N)
	result=zeros(1,K);
	fprintf('Assincrono\n');
	for i=1:K
		Yant = Pn(:,i);
		pos = ceil(rand(1,1)*N);
		Ynew = Yant;
		Yaux = sign(W*Yant);
		Ynew(pos)=Yaux(pos);
		cont =1;
		while norm(Yant-Yaux)>0
			cont = cont+1;
			pos = ceil(rand(1,1)*N);
			Yant = Ynew;
			Yaux = sign(W*Yant);
			Ynew(pos)=Yaux(pos);
		end
		fprintf('Figura: %s Passos %d\n',label(i),cont);
		%plot_figures(Ynew',1,res(1),res(2));
		if Ynew == P(:,i)
			result(i)=1;
		end
	end
end