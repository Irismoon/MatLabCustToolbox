function [N,x_class] = histogram_categorical(x,group)
x_class = unique(x);
edge = [8.5:1:12.5];
group_class = {'h2bg6f','nacre'};

k=0;
N = zeros(length(edge)-1,2);
for iG = col2row(group_class,1)
    k = k+1;
    N(:,k) = histcounts(x(ismember(group,iG)),edge);
end
end

