function mark_line(ax,x)
numline = length(x);
for i=1:numline
    line(ax,[x(i) x(i)],ax.YLim,'LineStyle','--','Color','k','LineWidth',1);
end
end

