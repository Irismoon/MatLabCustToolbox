function [x,y] = autopermute(x,y)
%permute the x ,y into dimension consistent with x
%e.g. x:3 x 2, y:4 x 3, [x(3 x 2),y(3 x 4),dim(1)] = autopermute(x,y)
%dim means they align along the dimth dimension/they have the same
%dimension at dim
sz1 = size(x);
sz2 = size(y);
[~,ia,ic] = intersect(sz1,sz2);
if ia==1
    x = permute(x,[2 1]);
end
if ic==1
    y = permute(y,[2 1]);
end
