function teste()
%AND
%{
Xtr = [0 0;1 0;0 1;1 1];
Ydtr = [0;0;0;1];
Xvl = [];
Ydvl = [];
%}

%OR
%{
Xtr = [0 0;1 0;0 1;1 1];
Ydtr = [0;1;1;1];
Xvl = [];
Ydvl = [];
%}

%XOR
%{
Xtr = [0 0;1 0;0 1;1 1];
Ydtr = [0;1;1;0];
Xvl = [];
Ydvl = [];
%}

treinamento = load("treinamento.txt");
teste = load("teste.txt");
[Xtr,Ydtr,Xts,Ydts] = processaDados(treinamento,teste);
Nts = size(Xts,1);
Xts = [Xts, ones(Nts,1)];
Xvl = [];
Ydvl=[];

[A,vErroTr,~] = perceptron(Xtr, Ydtr, Xvl, Ydvl);
plot(vErroTr);
[Y,~] = calcSaida(Xts,Ydts,A);
disp(Y);
end