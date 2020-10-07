function groupLabel = groupLabel(X)
%groupLabel = groupLabel(X)
%e.g. x = [2 3 4;5 6 7;8 9 10];
%groupLabel = [1;1;1;2;2;2;3;3;3]
%usually used for boxplot function 
%vector
if iscell(X)
    len = cellfun(@length,X);
    groupLabel = arrayfun(@(i) i*ones(len(i),1),1:length(len),'un',0);
    groupLabel = cat(1,groupLabel{:});
else
    [sampleLen,noVar] = size(X);
    groupLabel = reshape((1:1:noVar) + zeros(sampleLen,noVar),[],1);
end
end

