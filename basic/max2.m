function [M,row,col] = max2(X)
%function [M,row,col] = max2(X)
%This function returns the location of the maximum element of a matrix
%while the max of matlab builtin only returns column maximum e;ement
[M,I] = max(X(:));
[row,col] = ind2sub(size(X),I);
end

