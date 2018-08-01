%{
Função para realizar o teste da melhor mistura entregue. Para executar
basta inserir o caminho para o conjunto de teste. A melhor mistura será
carregada de misturaBest.mat
As matrizes de pesos da gating e dos especialistas podem ser obditas do
objeto carregado.
%}
function [Ym,EQM] = testeMisturaBest()
	lagMax=35;
	%Carrega o treinamento para pegar a media, o desvio e dados atrasados
	%do primeiro teste.
	treinamento = load("treinamento.txt");
	%Acha o melhor lag que foi usado.
	lagBest = ProcessaDados.achaLag(treinamento,lagMax);
	%Pega a media e desvio.
	[~,~,~,~,media,desvio] = ProcessaDados.processaTreinamento(treinamento,lagBest,0.3);
	%Carrega o teste
	teste = load("teste.txt"); %<-Caminho para o conjunto de teste aqui.
	Xts = ProcessaDados.processaTeste(treinamento,teste,lagBest,media,desvio);
	%Carrega a melhor rede
	l = load(['resultados',filesep,'misturaBest.mat']);
	misturaBest = l.misturaBest;
	%Testa a rede.
	misturaBest.teste(Xts);
	Ym = misturaBest.Ym;
	erro = misturaBest.Ym(1:end-1,1) - teste(2:end,1);
	EQM  = (1/size(Xts,1)*sum(sum(erro.*erro)));
end