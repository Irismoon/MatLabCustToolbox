%##################################################################
% Uses the fiedler vector to assign nodes to groups.
%
% INPUTS: adjacency matrix (nxn), k - desired number 
%         of nodes in groups [n1, n2, ..], [optional].
%         The default k is 2.
% OUTPUTs: modules - [k] partitioned groups of nodes
%
% Example:
% simpleSpectralPartitioning(random_modular_graph(100,4,0.15,0.9),
%                                                  [25 25 25 25])
% Other functions used: fiedlerVector.m
% Note: To save the plot at the end of the routine, uncomment:
%                   print filename.pdf (or filename.extension)
% GB: last updated, Oct 10 2012
%##################################################################

function modules = simpleSpectralPartitioning(adj,k)

% find the Fiedler vector: eigenvector corresponding to the second smallest eigenvalue of the Laplacian matrix
fv = fiedlerVector(adj);
[~,I]=sort(fv);

% depending on k, partition the nodes
if nargin==1
    
    modules{1}=[]; modules{2}=[];
    % choose 2 groups based on signs of fv components
    for v=1:length(fv)
        if fv(v)>0; modules{2} = [modules{2}, v]; end
        if fv(v)<=0; modules{1} = [modules{1}, v]; end
    end
end

if nargin==2

  k = [0 k];
    
  for kk=1:length(k)
        
    modules{kk}=[];
    for x=1:k(kk); modules{kk} = [modules{kk} I(x+k(kk-1))]; end
         
  end

  modules = modules(2:length(modules));
end

set(gcf,'Color',[1 1 1])
subplot(1,2,1)
plot(fv(I),'k.');
xlabel('index i')
ylabel('fv(i)')
title('sorted fiedler vector')
axis tight
axis square

subplot(1,2,2)
spy(adj(I,I),'k.')
axis square
title('sorted adjacency matrix')

%print spec_part_example.pdf