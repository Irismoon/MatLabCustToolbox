function X = tril2full(A)
%function X = tril2full(A)
%this function is to transform a lower triangular matrix filled with nan into a full symmmetrical matrix
%A could carry diag or not
[nrow,ncol] = size(A);
X = zeros(nrow,ncol);
X = tril(A) + tril(A)';
X((1:nrow)+nrow*(0:nrow-1)) = diag(A);
end

