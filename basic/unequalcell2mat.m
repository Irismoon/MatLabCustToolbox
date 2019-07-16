function A= unequalcell2mat(A)
%complete the unequal cell data by nan
if iscell(A)
    var = length(A);
    sample = max(cellfun(@length,A));
    A = cellfun(@(x) row2col(x,1),A,'un',0);
    A = cellfun(@(x) [x;nan(sample - length(x),1)],A,'un',0);
    A = cat(2,A{:});
end
end

