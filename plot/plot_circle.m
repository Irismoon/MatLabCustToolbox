function [outputArg1,outputArg2] = plot_circle(r,center,c)
% function [outputArg1,outputArg2] = plot_circle(r,center)
x = r(1)*sin(0:0.1:2*pi);
y = r(2)*cos(0:0.1:2*pi);
fill(x+center(1),y+center(2),c,'FaceAlpha',0.4,'EdgeAlpha',0);
end

