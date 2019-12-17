function [outputArg1,outputArg2] = supertitle(str)
fig = gcf;
figpos = get(gcf,'Position');
titleheight = (get(gcf,'defaultaxesfontsize')+2)/72*96;%points to pixel
ax = findobj(gcf,'Type','axes');
oldUnits = get(ax,'Units');
axpos = zeros(length(ax),4);
for i=1:length(ax)
    if ~strcmp(get(ax(i),'Units'),'pixels')
        set(ax(i),'Units','pixels');
        ax(i).OuterPosition(2) = ax(i).OuterPosition(2) - titleheight;
    end
end
fig.Position(2) = fig.Position(2) - titleheight;
fig.Position(4) = fig.Position(4) + titleheight;

fig.NextPlot = 'add';
axes('pos',[0 1 1 1],'Visible','off');
ht=text(.5,0.95-1,str);set(ht,'horizontalalignment','center');
end

