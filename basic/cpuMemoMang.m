function [npoint,idx]= cpuMemoMang(J)
%This function is to manage the memory during computation
%Cpt: f x chn x taper x trial
[numf,numchn,numtaper,numtrial] = size(J);
point = nchoosek(1:numchn,2);
point = point(:,[2 1]);
[~,sysmem] = memory;
safct = 0.5;
tmp = whos('J');
memperunit = tmp.bytes/numchn;
availablepoint = fix(sysmem.PhysicalMemory.Available*safct/2/memperunit);
cycle = ceil(size(point,1)/availablepoint);
sizecycle = availablepoint;
npoint = cell(cycle,1);
idx = cell(cycle,1);
for j = 1:cycle
    if j~=cycle
        npoint{j} = point((j-1)*sizecycle+(1:sizecycle),:);
    else
        npoint{j} = point((j-1)*sizecycle+1:end,:);
    end
    x = npoint{j}(:,1);y = npoint{j}(:,2);
%      idx{j} = sub2ind([numchn numchn numf],reshape(repmat(x,1,numf)',[],1),reshape(repmat(y,1,numf)',[],1),...
%             reshape(repmat((1:numf)',1,length(x)),[],1));
    tmp = sub2ind([numchn numchn],x,y)+[0:numchn*numchn:(numf-1)*numchn*numchn];
    idx{j} = reshape(tmp',[],1);
end
assert(sum(cellfun(@(x) size(x,1),npoint))==length(point),'not equal pairs!');
end

