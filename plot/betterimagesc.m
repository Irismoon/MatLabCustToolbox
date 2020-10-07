function [outputArg1,outputArg2] = betterimagesc(x,y,z,ax)
%function [outputArg1,outputArg2] = betterimagesc(x,y,z)
%this function plot imagesc with x and axis tick label
%e.g. x: 1:10, y: 5:14, for z, the lowerleft corner coordinate of Z is
%(1,5) and the upperright corner of z is (10,14);
if nargin<4
    figure,
    ax = gca;
end
y = flip(y);
imagesc(ax,'XData',x,'YData',y,'CData',z);
end

