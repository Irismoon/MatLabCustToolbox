function Xo = indexbycolumn(X,index)
%Xo = colidx(X,index)
%perm the element of X in terms of column by index 
%e.g.X=
% [1 2 3 
%  4 5 6
%  7 8 9], 
% y=[1 2 3
%  2 1 2
%  3 3 1], 
%X(y) = [1 5 9
%        4 2 6
%        7 8 3];
assert(all(size(X)==size(index)),'The data and index must be the same size!')
sz = size(X);
[X,index] = samfnmultvar(@(x) x(:,:),X,index);
tmp = arrayfun(@(i) X(index(:,i),i),1:size(X,2),'un',0);
Xo = cat(2,tmp{:});
Xo = reshape(Xo,sz);
end

