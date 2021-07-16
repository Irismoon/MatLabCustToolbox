function y = nearestOdd(x)
%y = nearestOdd(x)
%if x is odd at its integer place, floor(x); if x is even, ceil(x)
%if x is 1.2, y=1, x=1.8,y=1; x=2.2/2.8, y=3,
if mod(floor(x),2)==1
    y = floor(x);
else
    y = ceil(x);
end
end

