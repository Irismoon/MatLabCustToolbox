function el = rewireThisEdge(el,i1,i2)
%REWIRETHISEDGE Degree-preserving rewiring of 1 given edge.
% Note 1: Assume unweighted undirected graph.
% 
% @input el, Mx3 edgelist of M edges 
% @input il1, first node to be rewired
% @input il2, second node to be re-wired
% @output el, Mx3 edge list, same size and same degree distribution
%
% Note: There are cases when rewiring is not possible, while
%       keeping the graph simple, so an empty edge list is returned.
% 
% Other routines used: edgeL2adj.m, kneighbors.m

% Updated: cleaned fprintf
% IB: last updated, 3/24/14


%%  check whether the edge can actually be rewired
adj = edgeL2adj(el);
neighbors = [i1, i2];
neighbors = [neighbors kneighbors(adj,i1,1)];
neighbors = [neighbors kneighbors(adj,i2,1)];

disjoint_edges = [];
for e=1:length(el)
  if sum(ismember(neighbors,el(e,1)))==0 & sum(ismember(neighbors,el(e,2)))==0
    disjoint_edges = [disjoint_edges; el(e,:)];
  end
end

if isempty(disjoint_edges)
  fprintf('cannot rewire this graph without adding a double edge or a loop\n');
  el = [];
  return
end
% .................................................................

[~,row] = ismember([i1 i2 1],el,'rows');
ind = [row];
edge1=el(ind(1),:);


%% pick a random second edge from the disjoint edges
randind = randi([1,size(disjoint_edges,1)]);
edge2=disjoint_edges(randind,:);
  
[~,ind2] = ismember([edge2(1) edge2(2) 1],el,'rows');
ind = [ind ind2];
    
    
if rand<0.5
  
  % first possibility: (e11,e22) & (e12,e21)
  el(ind(1),:)=[edge1(1),edge2(2),1];
  el(ind(2),:)=[edge1(2),edge2(1),1];
    
  % add the symmetric equivalents
  [~,inds1] = ismember([edge1(2),edge1(1),1],el,'rows');
  el(inds1,:)=[edge2(2),edge1(1),1];
    
  [~,inds2] = ismember([edge2(2),edge2(1),1],el,'rows');
  el(inds2,:)=[edge2(1),edge1(2),1];
  
else
  
  % second possibility: (e11,e21) & (e12,e22)
  el(ind(1),:)=[edge1(1),edge2(1),1];
  el(ind(2),:)=[edge1(2),edge2(2),1];
    
  % add the symmetric equivalents
  [~,inds1] = ismember([edge1(2),edge1(1),1],el,'rows');
  el(inds1,:)=[edge2(1),edge1(1),1];
    
  [~,inds2] = ismember([edge2(2),edge2(1),1],el,'rows');
  el(inds2,:)=[edge2(2),edge1(2),1];
     
end