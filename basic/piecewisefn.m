function idata = piecewisefn(fun,data,varargin)
%idata = piecewisefn(fun,data,varargin)
%varargin: 'edge',[1 20 40 60] OR 'label', label;
%data : vector or multidim array
p=inputParser;
addRequired(p,'func',@(x) isa(x,'function_handle'));
addRequired(p,'data');
addParameter(p,'edge',nan);
addParameter(p,'label',nan);
parse(p,fun,data,varargin{:});
edge = p.Results.edge;
label = p.Results.label;
data = p.Results.data;
fun = p.Results.func;
assert(all(~isnan(edge))||any(~isnan(label)),'please provide the edge or label!');
S.type = '()';

if all(~isnan(edge))
    idata = cell(length(edge)-1,1);
    S.subs = [{edge(1):edge(2)};repmat({':'},ndims(data)-1,1)];
    idata{1} = (fun(subsref(data,S)));
    for i=2:length(edge)-1
        S.subs = [{edge(i)+1:edge(i+1)};repmat({':'},ndims(data)-1,1)];
        idata{i} = (fun(subsref(data,S)));
    end
    idata = cat(1,idata{:});
elseif any(~isnan(label))
    ulabel= unique(label(~isnan(label)));
    idata = cell(length(ulabel),1);
    for i=1:length(ulabel)
        S.subs = [{find(label==ulabel(i))};repmat({':'},ndims(data)-1,1)];
        idata{i} = fun(subsref(data,S));
    end
    if iscell(data)
    else
    idata = cat(1,idata{:});
    end
else
    error;
end
end

