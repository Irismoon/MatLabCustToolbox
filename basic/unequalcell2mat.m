function A= unequalcell2mat(A)
%A= unequalcell2mat(A)
%A: cell array
%complete the unequal cell data by nan
if iscell(A)
    var = length(A);
    sz = cellfun(@length,A);
    sample = max(sz(:));
    A = cellfun(@(x) row2col(x,1),A,'un',0);
    A = cellfun(@(x) [x;nan(sample - length(x),1)],A,'un',0);
    A = reshape(cat(2,A{:}),[sample size(A)]);
end
end

