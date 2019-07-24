function [pair,p] = multicompare2(func,A)
%[pair,p] = multicompare(func,A)
%func: function handle, e.g.ranksum(x,y)
%A: sample x var matrix or var x 1 cell vector
assert(isa(func,'function_handle'),'Please Provide a function handle!');
if iscell(A)
    A = unequalcell2mat(A);
end%sample x var with nan
[sample,var] = size(A);
pair = nchoosek(1:var,2);
pairNo = size(pair,1);
Ap = reshape(A(:,pair),sample,pairNo,2);
p = arrayfun(@(i) func(Ap(:,i,1),Ap(:,i,2)),1:pairNo);
end

