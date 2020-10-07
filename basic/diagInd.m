function idx = diagInd(n)
%idx = diagInd(n)
%n is a number denoting the dimension along any axis of a square matrix
idx = (0:1:n-1)*n + (1:n);
end

