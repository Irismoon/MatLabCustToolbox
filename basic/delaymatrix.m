function Xnew = delaymatrix(X,k)
%create the delay matrix of X, such that the first row of X becomes [X(1,1)... X(1,d) X(2,1)...X(2,d) X(3,1)...X(3,d)...]
[numT,numd] = size(X);
Xtmp = arrayfun(@(i) X((i+1):(i+numT-k),:),0:k,'un',0);
Xnew = cat(2,Xtmp{:});
Xnew = [Xnew;Xnew(end-k+1:end,:)];
end

