function [xquery,row,col] = maxabs(x)
[~,I] = max(abs(x),[],'all','linear');
[row,col] = ind2sub(size(x),I);
xquery = x(row,col);
end

