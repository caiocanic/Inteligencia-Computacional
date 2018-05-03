function [Xtr,Ydtr,Xts,Ydts] = processaDados(treinamento,teste)
	[Xtr,Ydtr,media,desvio] = processaTreinamento(treinamento);
	[Xts,Ydts] = processaTeste(teste,media,desvio);
end

function [Xtr,Ydtr,media,desvio] = processaTreinamento(treinamento)
	Ntr = size(treinamento,1);
	%Separa a saída desejada
	classesTr = treinamento(:,end);
	nroClasses = max(classesTr);
	Ydtr = zeros(Ntr,nroClasses);
	%Rotula as classes
	for i=1:Ntr
		Ydtr(i,classesTr(i)) = 1;
	end
	%Normaliza o treinamento
	Xtr = treinamento(:,1:end-1);
	ne = size(Xtr,2);
	media = mean(Xtr);
	desvio = std(Xtr);
	for i=1:ne
		Xtr(:,i) = (Xtr(:,i)-media(i))/desvio(i);
	end
end

function [Xts,Ydts] = processaTeste(teste,media,desvio)
	Nts = size(teste,1);
	%Separa a saída desejada
	classesTs = teste(:,end);
	nroClasses = max(classesTs);
	Ydts = zeros(Nts,nroClasses);
	%Rotula as classes
	for i=1:Nts
		Ydts(i,classesTs(i)) = 1;
	end
	%Normaliza o treinamento
	Xts = teste(:,1:end-1);
	ne = size(Xts,2);
	for i=1:ne
		Xts(:,i) = (Xts(:,i)-media(i))/desvio(i);
	end
end