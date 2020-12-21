function idx = index_diag(X)
[nrow,ncol] = size(X);
if nrow==ncol & nrow>1
    n = size(X,1);
elseif abs(numel(X)-1)<0.0001
    n = X;
else
    warning('unrecognized input!');
end
idx = [1:n] + n*(0:n-1);
end