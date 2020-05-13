function [y] = row2col(data,chn)
%function [y] = row2col(data,chn)
%default: chn=1
if nargin<2
    chn = 1;
end
[row,col] = size(data);
if row==0
    y=[];
else
if row == chn
    y = data';
elseif col == chn
    y = data;
end
end
end

