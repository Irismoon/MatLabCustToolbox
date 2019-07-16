function [y] = row2col(data,chn)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
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

