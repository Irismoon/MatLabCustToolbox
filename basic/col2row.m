function y = col2row(data,chn)
%y = col2row(data,chn)
%default, chn=1
[row,col] = size(data);
if nargin<2
    chn = 1;
end
if col == chn
    y = data';
elseif row == chn
    y = data;
end
end

