function [pair,p] = multcompare2(func,A)
%[pair,p] = multicompare(func,A)
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

