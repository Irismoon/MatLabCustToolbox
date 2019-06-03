function y = col2row(data,chn)
[row,col] = size(data);
if col == chn
    y = data';
elseif row == chn
    y = data;
end
end

