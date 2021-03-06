%{
Objeto responsável por representar a função matemática que será otimizada
por meio do Algorítmo Genético.
Atributos
nome: Nome da função matemática que o objeto representa.
calcula: Function handle que aponta para o método que gera a saída da
função matemática selecionada ao criar o objeto.
intervaloBusca: Intervalo de busca no qual a função será otimizada.
precisao: Precisão com a qual a otimização será feita.
%}
classdef Funcao
	properties
		nome
		calcula
		intervaloBusca
		precisao
	end
	
	methods
		%{
		Método construtor
		Parâmetros
		nome: Nome da função matemática que esse objeto irá representar. É
		utilizado para chamar o método apropriado para cálculo da saída.
		intervaloBusca: Intervalo no qual a função será otimizada.
		precisão: Precisão com a qual a otimização será feita.
		%}
		function funcao = Funcao(nome,intervaloBusca,precisao)
			funcao.nome = nome;
			funcao.calcula = str2func(['Funcao.',nome]);
			funcao.intervaloBusca = intervaloBusca;
			funcao.precisao = precisao;
		end
	end
	
	methods (Static=true, Access=private)
		%{
		Goldstein & Price Function
		Intervalo de busca sugerido para X [-2,2]
		Mínimo y=3,X(0,-1)
		N=2
		%}
		function y = gold(X)
			a = 1+(X(1)+X(2)+1)^2*(19-14*X(1)+3*X(1)^2-14*X(2)+6*X(1)*X(2)+3*X(2)^2);
			b = 30+(2*X(1)-3*X(2))^2*(18-32*X(1)+12*X(1)^2+48*X(2)-36*X(1)*X(2)+27*X(2)^2);
			y = a*b;
		end
		
		%{
		Sum Squares function
		Intervalo de busca sugerido para X [-10,10] ou [-5.12, 5.12]
		Mínimo y=0,X(0,0)
		N>=2
		%}
		function y = sumS(X)
			n = size(X,2);
			s = 0;
			for j = 1:n  
				s=s+j*X(j)^2; 
			end
			y = s;
		end
		
		%{
		DeJong function
		Intervalo de busca sugerido para X [-2,2]
		Mínimo y=0, X(-1,-1), X(-1,1), X(1,-1) e X(1,1)
		N=2
		%}
		function y = deJong(X)
			y = 100*(X(1)^2-X(2)^2)^2+(1-X(1)^2)^2;
		end
		
		%{
		Ackley function
		Intervalo de busca sugerido para X [-32.768, 32.768]
		Mínimo y=0, X(0,0)
		N>=2
		%}
		function y = ackley(X)
			n = size(X,2);
			a = 20;
			b = 0.2;
			c = 2*pi;
			s1 = 0;
			s2 = 0;
			for i=1:n
				s1 = s1+X(i)^2;
				s2 = s2+cos(c*X(i));
			end
			y = -a*exp(-b*sqrt(1/n*s1))-exp(1/n*s2)+a+exp(1);
		end
		
		%{
		Bump function
		Intervalo de busca sugerido para X [0,10]
		Mínimo desconhecido (??)
		N=2;
		%}
		function y = bump(X)
			if (X(1)*X(2))<0.75
				y=NaN;
			elseif (X(1)+X(2))>7.5*2
				y=NaN;
			else
				temp0=cos(X(1))^4+cos(X(2))^4;
				temp1=2*(cos(X(1))^2)*(cos(X(2))^2);
				temp2=sqrt(X(1)^2+2*X(2)^2);
				y=-abs((temp0-temp1)/temp2);
			end
		end
		
		%{
		Rastrigin function
		Intervalo sugerido para X [-5.12, 5.12]
		Mínimo ???
		N>=2
		%}
		function y = rastrigin(X)	
			y=sum(X.^2-10*cos(2*pi*X)+10);
			y=-y;
		end
	end
end