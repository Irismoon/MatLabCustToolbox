function nx = upperFirst(x,delim,flag)
prep = {'in','of','to','for','with','at','on','by','as','{','}'};
nx = strsplit(x,delim);%n x 1 cell vector
[lia,locb] = ismember(prep,nx);
objWordIndex = setdiff(1:length(nx),intersect(locb,1:length(nx)));
if strcmp(flag,'robust')
    nx(objWordIndex) = arrayfun(@(i) [upper(nx{i}(1)) lower(nx{i}(2:end))],...
        objWordIndex,'un',0);
else
    nx = arrayfun(@(i) [upper(nx{i}(1)) lower(nx{i}(2:end))],1:length(nx),'un',0);
end
nx = strjoin(nx);
end

