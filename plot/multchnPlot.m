function figlist = multchnPlot(x,t,markt,varargin)
%figlist = multchnPlot(x,t,markt,stdx(op),chnname(op),pnname(op),auto(op),layout(op),‘plotstyle’,'plot')
%x: ts x line x chn; the last dimension is one subplot
%t, 2 x 1 vector, start and end of a trial
%markt, any length vector
%stdx, standard deviation of x for boundplot,t x 2 x line x chn
%chnname, pnname,
%layout: the layout of whole figure
%lplotstyle: 'boundplot','plot','imagesc'
%auto: 1 is autoadjust, 0 is not autoadjust
%example, multchnPlot(x,[-0.5,0.1],[0],[],chnname,'plotstyle','plot');
sz = size(x);
if length(sz)<3
    sz = [sz 1];
end
p = inputParser;
addRequired(p,'x',@isnumeric);
addRequired(p,'t',@isnumeric);
addRequired(p,'markt',@isnumeric);
addOptional(p,'boundwidth',nan(sz),@isnumeric);
addOptional(p,'chnname',repmat({''},sz(3),1),@iscell);
addOptional(p,'pnname',0,@isnumeric);
addOptional(p,'auto',true,@islogical);
addOptional(p,'layout',[5 5],@isvector);
addParameter(p,'plotstyle','imagesc',@ischar);

parse(p,x,t,markt,varargin{:});
x = p.Results.x;
t = p.Results.t;
markt = p.Results.markt;
stdx = p.Results.boundwidth;
chnname = p.Results.chnname;
pnname = p.Results.pnname;
auto = p.Results.auto;
layout = p.Results.layout;
plotstyle = p.Results.plotstyle;

global fs;
if abs(ndims(x)-ndims(stdx))<1e-6
    stdx = reshape(stdx,sz(1),1,sz(2),sz(3));
end
if ismatrix(x)
    x = reshape(x,sz(1),sz(2),1);
end
sz = size(x);
chnNo = size(x,3);
if auto
    [layout(1),layout(2)] = arrange_subplots(min(chnNo,25));
end
figlist = [];
cmap = brewermap(sz(2),'Set1');
for i = 1:chnNo
    if mod(i,prod(layout))==1 || prod(layout==1)
        fh = figure('units','normalized','outerposition',[0 0 1 1]);
        figlist = [figlist;fh];
    end
    if mod(i,prod(layout))==0
%         subplot_tight(layout(1),layout(2),prod(layout));
          subplot(layout(1),layout(2),prod(layout));
    else
%         subplot_tight(layout(1),layout(2),mod(i,prod(layout)));
          subplot(layout(1),layout(2),mod(i,prod(layout)));
    end
    %     eval([plotstyle,'(x(:,:,i))'])
    switch plotstyle
        case 'boundplot'
            h1 = boundedline(linspace(t(1),t(end),sz(1)),x(:,:,i),...
                stdx(:,:,:,i),'alpha','cmap',cmap);
            [h1.LineWidth] = deal(2);
            ax = gca;
            ax.XTick = sort([t(1) markt t(2)]);
            axis tight;
            hold on;
            arrayfun(@(i) line([markt(i) markt(i)],ax.YLim,'Color','k','LineStyle','--','LineWidth',1.5),...
                1:length(markt),'un',0);           
        case 'plot'
            plot(linspace(t(1),t(end),sz(1)),x(:,:,i));%ts x trial
            xlabel('t/s');ylabel('power/dB');
            ax = gca;ax.XLim = [t(1) t(end)];
            hold on;
            arrayfun(@(i) line([markt(i) markt(i)],ax.YLim,'Color','k','LineStyle','--','LineWidth',1.5),...
                1:length(markt),'un',0);
        case 'imagesc'
            imagesc(x(:,:,i)');%trial x ts
            colorbar;
            colormap jet;
            ax = gca;ax.XLim = [1 sz(1)];ax.YLim = [1 sz(2)];
            ax.XTick = [1 (markt-t(1))*fs sz(1)];
            tmp = col2row(arrayfun(@(i) num2str(markt(i),2),1:length(markt),'un',0),1);
            ax.XTickLabel = [num2str(t(1),2),tmp,num2str(t(end),2)];
            hold on;
            arrayfun(@(i) line(fs*([markt(i) markt(i)]-t(1)),ax.YLim,'Color','k','LineStyle','--','LineWidth',1.5),...
                1:length(markt),'un',0);
        otherwise
            warning('no appropriate plotstyle, should be: boundplot, plot, imagesc')
    end
    
    title(chnname{i});
    if mod(i,prod(layout))==0 || i==chnNo
%         suptitle(num2str(pnname));
    end
end

