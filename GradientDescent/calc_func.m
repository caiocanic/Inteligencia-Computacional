function [f,g,h] = calc_func(X)
	f = (X(1)-2)^2 + (X(2)-3)^2;
	g = [2*(X(1)-2); 2*(X(2)-3)];
	h = [2 0; 0 2];
end