function groupLabel = groupLabel(X)
%groupLabel = groupLabel(X)
%usually used in boxplot function or similar function which need to use the
%groupLabel to recognize data belonging to different groups but in one
%vector
if iscell(X)
    len = cellfun(@length,X);
    groupLabel = arrayfun(@(i) i*ones(len(i),1),1:length(len),'un',0);
else
    [sampleLen,noVar] = size(X);
    groupLabel = reshape((1:1:noVar) + zeros(sampleLen,noVar),[],1);
end
end

