function [y] = change_row_to_col(data,chn)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[row,col] = size(data);
if row == chn
    y = data';
elseif col == chn
    y = data;
end
end

