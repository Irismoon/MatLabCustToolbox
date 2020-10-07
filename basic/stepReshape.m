function y = stepReshape(x,win,stepwin)
%y = stepReshape(x,win, stepwin)
%to reshape the x with overlap, e.g. [1,1,1;1,2,2;2 2 3] = stepReshape([1,1,1,2,2,2,3],3,2)
%x, time 
%varargin: win,
NoWin = (length(x)-stepwin)/stepwin;
y = zeros(win,NoWin);
for i = 1:NoWin
    y(:,i) = x(stepwin*(i-1)+(1:win));
end
end

