function printset(varargin)
%to minimize the margin between figure window and axes window
if isempty(varargin)
    fig=gcf;
else
    fig = varargin{1};
end
%make the axes best fill the figure
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig.PaperPositionMode = 'auto';
fig.PaperSize = fig.PaperPosition([3 4]);
end

