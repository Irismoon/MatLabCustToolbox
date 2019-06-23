function figlist = multchnPlot(x,t,markt,layout,plotstyle,auto,chnname,pnname)
%figlist = multchnPlot(x,t,markt,layout,plotstyle,auto,chnname,pnname)
%x: ts x chn, or ts x trial x chn; the last dimension is one subplot
%layout: the layout of whole figure
%lplotstyle: 'plot','imagesc'
%auto: 1 is autoadjust, 0 is not autoadjust
global fs;
sz = size(x);
if abs(ndims(x)-2)<1e-6
    x = reshape(x,sz(1),sz(2),1);
end
sz = size(x);
chnNo = size(x,3);
if auto
    [layout(1),layout(2)] = arrange_subplots(min(chnNo,25));
end
figlist = [];
for i = 1:chnNo
    if mod(i,prod(layout))==1 || prod(layout==1)
        fh = figure('units','normalized','outerposition',[0 0 1 1]);
        figlist = [figlist;fh];
    end
    if mod(i,prod(layout))==0
        subplot(layout(1),layout(2),prod(layout));
    else
        subplot(layout(1),layout(2),mod(i,prod(layout)));
    end
%     eval([plotstyle,'(x(:,:,i))'])
    switch plotstyle
        case 'plot'
            plot(t,x(:,:,i));%ts x trial
            xlabel('t/s');ylabel('power/dB');
            ax = gca;ax.XLim = [t(1) t(end)];
        case 'imagesc'
            imagesc(x(:,:,i)');%trial x ts
            colorbar;
            colormap jet;
            ax = gca;ax.XLim = [1 sz(1)];ax.YLim = [1 sz(2)];
            ax.XTick = [1 (markt-t(1))*fs sz(1)];
            tmp = col2row(arrayfun(@(i) num2str(markt(i),2),1:length(markt),'un',0),1);
            ax.XTickLabel = [num2str(t(1),2),tmp,num2str(t(end),2)];
    end     
    hold on;
    arrayfun(@(i) line(fs*([markt(i) markt(i)]-t(1)),ax.YLim,'Color','k','LineStyle','--','LineWidth',1.5),...
        1:length(markt),'un',0);
    title(chnname{i});
    if mod(i,prod(layout))==0 || i==chnNo
        suptitle(num2str(pnname));
    end
end

