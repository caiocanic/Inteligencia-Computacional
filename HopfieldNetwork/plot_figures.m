%Recebe uma matriz contendo K figuras em preto e branco e plota cada uma delas na resolução hxw.
%Parámetros:
%figures: matríz KxN de figuras;
%K: Número de figuras na matriz;
%w: largura da imagem em pixels;
%h: altura da imagem em pixels;
function plot_figures(figures, K,w,h)
	map = [ 1 1 1;0 0 0];
	
	for i=1:K
		figure=reshape(figures(i,:),w,h)';
		image((figure>0)+1)
		colormap(map)
		pause
	end
end