function plot_evolution_trajectory(X,varargin)
%plot_evolution_trajectory(X,'marker',[start end],'color',color,'delay',0.02);
markerflag = find(cellfun(@(x) strcmp(x,'marker'),varargin));
colorflag = find(cellfun(@(x) strcmp(x,'color'),varargin));
plottypeflag = find(cellfun(@(x) strcmp(x,'plottype'),varargin));
delaytimeflag = find(cellfun(@(x) strcmp(x,'delay'),varargin));
if ~isempty(markerflag)
    marker = varargin{markerflag+1};
else
    marker = [];
end
if ~isempty(colorflag)
    color = varargin{colorflag+1};
else
    color = jet(size(marker,1));
end
if ~isempty(plottypeflag)
    plottype = varargin{plottypeflag+1};
else
    plottype = 'plot';
end
if ~isempty(delaytimeflag)
    delaytime = varargin{delaytimeflag+1};
else
    delaytime = 0.002;
end
figure,
timepoints = size(X,1);
xlim = [min(X(:,1)) max(X(:,1))];
ylim = [min(X(:,2)) max(X(:,2))];
for i=1:timepoints
    cla;
    set(gca,'XLim',xlim,'YLim',ylim);
    plot(X(1:i,1),X(1:i,2));
    hold on;
    scatter(X(i,1),X(i,2),'filled');grid on;
    %
    if ~isempty(marker)
        markertmp = marker(marker(:,2)<i,:);
        colortmp = color(marker(:,2)<i,:);
        if strcmp(plottype,'plot')
            arrayfun(@(i) plot(X(markertmp(i,1):markertmp(i,2),1),X(markertmp(i,1):markertmp(i,2),2),'Color',colortmp(i,:)),1:size(markertmp,1),'un',0);
        elseif strcmp(plottype,'scatter')
            arrayfun(@(i) scatter(X(markertmp(i,1),1),X(markertmp(i,1),2),10,colortmp(i,:),'filled'),1:size(markertmp,1),'un',0);
            arrayfun(@(i) scatter(X(markertmp(i,2),1),X(markertmp(i,2),2),30,colortmp(i,:),'filled'),1:size(markertmp,1),'un',0);
        end
    end
    if i>5 scatter(X(i-5:i,1),X(i-5:i,2),10,rgb({'brown'}),'*'); end
    title(num2str(i));
    pause(delaytime);
    %     pause;
end
% scatter(X(marker,1),X(marker,2),20,color,'filled');