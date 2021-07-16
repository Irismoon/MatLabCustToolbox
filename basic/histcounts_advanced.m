function [N,Y] = histcounts_advanced(X,edges)
N = histcounts(X,edges);
Y = discretize(X,edges);
end

