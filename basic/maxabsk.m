function [value,I] = maxabsk(x,k)
[value,I] = maxk(abs(x),k);
value = x(I);
end