function copyPrint(fig)
if nargin<1
    fig = gcf;
end
% fig = arrayfun(@(i) fig(i),1:length(fig),'un',0);
print(fig,'-clipboard','-dbitmap');
end

