function h = boxplot2(varargin)
% h = boxplot2(y)
% h = boxplot2(y,x)
% h = boxplot2(..., p1, v1, ...)
%adjust cosmetic appearance by h,
%e.g. set(h.med,'color','k');
%structfun(@(x) set(x,'marker','*'),h),change the marker of each field
% Input variables:
%
%   y:              nx for each box cluster, ny for number of clusters
%                   1.ndata x nx array (as in boxplot) 2.nx x ny x
%                   ndata array where nx indicates the number of
%                   x-clusters, ny the number of boxes per cluster, and
%                   ndata the number of points per boxplot.3.nx x ny cell,
%                   inside a ndata x 1 vector, each cell may have different
%                   number of elements
%   example:        nx(2) x ny(3), two clusters, each 3 boxes
%
%   x:              vector of x locations for each box cluster
%
% Optional input variables (passed as parameter/value pairs)
%
%   notch:          'on' or 'off' ['off']
%
%   orientation:    'vertical' or 'horizontal' ['vertical']
%
%   barwidth:       Barwidth value used to position boxes (see bar) [0.8]
%
%   whisker:        whisker length factor (see wboxplot) [1.5]
%
%   axes:           axis to plot to [gca]
%
% Output variables:
%
%   h:              structure of handles to boxplot, with the following
%                   fields: 
%                   'box':      box
%                   'ladj':     lower adjacent value
%                   'lwhis':    lower whisker
%                   'med':      median
%                   'out':      outliers
%                   'uadj':     upper adjacent value
%                   'uwhis':    upper whisker    
%
% This version creates more light-handed boxplots, assuming that any cosmetic
% changes (color, tick labels, line specs, etc) can be added by the user
% afterwards if necessary.  It also allows one to create clustered
% boxplots, similar to an unstacked bar graph.
% Copyright 2012 Kelly Kearney       

% Parse input

p = inputParser;
p.addRequired('y', @(x) isnumeric(x)|iscell(x));
p.addOptional('x', [], @isnumeric);
p.addParameter('PlotStyle','traditional',@ischar);
p.addParameter('notch', 'off', @ischar);
p.addParameter('orientation', 'vertical', @ischar);
p.addParameter('axes', gca, @(x) isscalar(x) && ishandle(x) && strcmp(get(x,'type'),'axes'));
p.addParameter('barwidth', 0.8, @(x) isscalar(x) && x > 0 && x <= 1);
% p.addParamValue('boxwidth', [], @(x) isscalar(x));
p.addParameter('whisker', 1.5, @(x) isscalar(x));


p.parse(varargin{:});

In = p.Results;
In.PlotStyle = validatestring(In.PlotStyle,{'traditional','compact'});
In.notch = validatestring(In.notch, {'on', 'off'});
In.orientation = validatestring(In.orientation, {'vertical', 'horizontal'});
if iscell(In.y)%nx x ny or nx x 1 cell\
    [nx,ny] = size(In.y);
    datalen = max(reshape(cellfun(@length,In.y),[],1));
    In.y = cellfun(@(x) reshape(x,[],1),In.y,'un',0);
    In.y = cellfun(@(x) [nan(datalen - length(x),1);x],In.y,'un',0);
    In.y = cell2mat(In.y);%
    In.y = permute(reshape(In.y,datalen,nx,ny),[2 3 1]);
end
if ndims(In.y) == 2
    In.y = permute(In.y, [2 3 1]);
end
[nx, ny, ndata] = size(In.y);
if isempty(In.x)
    In.x = 1:nx;
end

ybox = reshape(In.y, [], ndata)';

% Use bar graph to get x positions

figtmp = figure('visible', 'off');
try
    hax = axes(figtmp);
    hb = bar(In.x, In.y(:,:,1), In.barwidth);
    for ib = 1:length(hb)
        if verLessThan('matlab','8.4.0')
            xbar = get(get(hb(ib), 'children'), 'xdata');
            xb(:,ib) = mean(xbar,1);
        else
            xb(:,ib) = hb(ib).XData + hb(ib).XOffset;
        end
    end
    if verLessThan('matlab', '8.4.0')
        boxwidth = diff(minmax(xbar(:,1)));
    else
        if ny > 1
            boxwidth = diff([hb(1:2).XOffset])*In.barwidth;
        else
            mindx = min(diff(In.x));
            boxwidth = mindx .* In.barwidth;
        end
    end
    delete(hb);

    boxplot(hax,ybox, 'positions', xb(:), ...
                   'PlotStyle',In.PlotStyle,...
                  'notch', In.notch, ...
                  'orientation', In.orientation, ...
                  'symbol', '+', ...
                  'widths', boxwidth, ...
                  'whisker', In.whisker);
    
    h.box   = copyobj(findall(hax, 'tag', 'Box'), In.axes);
    h.ladj  = copyobj(findall(hax, 'tag', 'Lower Adjacent Value'), In.axes);
    h.lwhis = copyobj(findall(hax, 'tag', 'Lower Whisker'), In.axes);
    h.med   = copyobj(findall(hax, 'tag', 'Median'), In.axes);
    h.out   = copyobj(findall(hax, 'tag', 'Outliers'), In.axes);
    h.uadj  = copyobj(findall(hax, 'tag', 'Upper Adjacent Value'), In.axes);
    h.uwhis = copyobj(findall(hax, 'tag', 'Upper Whisker'), In.axes);

    close(figtmp);
catch ME
    close(figtmp);
    rethrow(ME);
end

    h = structfun(@(x) reshape(flipud(x), ny, nx), h, 'uni', 0);



