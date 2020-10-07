function [Xout] = squareformY(X)
%X: numchn 
numchn = length(X);
numf = size(X{1},1);
Xout = zeros(numf,numchn,numchn);
for i=1:numchn
%     Xout(:,i,i) = ones(numf,1);
    for j=i+1:numchn
        Xout(:,j,i) = X{i}(:,j-i);
%         Xout(:,i,j) = Xout(:,j,i);
    end
end
end

