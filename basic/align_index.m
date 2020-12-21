function align_idx = align_index(X,Q)
%function align_idx = align_index(X,Q)
% [nSample,nDim] = size(X);
% [nDim,nK] = size(Q);
%align_idx is the explained variance along each reduced dimension
[nSample,nDim] = size(X);
[nDim,nK] = size(Q);
[U,S,V] = svd(X);
align_idx =diag(Q'*X'*X*Q)/sum(diag(S.^2));
end

