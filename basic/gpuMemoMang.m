function npair= gpuMemoMang(numchn,memperpair)
%npair= gpuMemoMang(numchn,memperpair)
%This function is to manage the memory during computation

point = nchoosek(1:numchn,2);
point = point(:,[2 1]);
% totalMemoR = length(point)*memperpair;%all required memory
% g = gpuDevice();
saf = 0.8;
% MemoAval = saf*g.AvailableMemory;
MemoAval = double(saf*intmax('int32'));%the limit of gpu is determined by 
pairNoperCycle = fix(MemoAval/memperpair);
cycle = ceil(length(point)/pairNoperCycle);
assert(pairNoperCycle*memperpair<=MemoAval,'available Memory not enough!');
npair = cell(cycle,1);
for j = 1:cycle
    if j~=cycle
        npair{j} = point(pairNoperCycle*(j-1)+(1:pairNoperCycle),:);
        
    else
        npair{j} = point(pairNoperCycle*(j-1)+1:end,:);
    end
end
assert(sum(cellfun(@(x) size(x,1),npair))==length(point),'not equal pairs!');
end

