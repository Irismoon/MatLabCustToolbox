function idx = edge2idxedge(x,edge)
%idx = edge2idxedge(x,edge)
%discretize x into the edge bin
%e.g.[1 2 1 2 2 nan]=edge2idxedge([1 4 3 5 5 9],[1 3;4 8]);
bin = size(edge,1);
idx = nan(length(x),1);
for i = 1:bin
    idx(x>=edge(i,1) & x<=edge(i,2)) = i;
end

end

