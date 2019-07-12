function idata = intervalfn(fun,data,varargin)
%idata = intervalfn(fun,data,varargin)
%varargin: 'edge',[1 20 40 60];
p=inputParser;
addRequired(p,'func',@(x) isa(x,'function_handle'));
addRequired(p,'data',@isnumeric);
addParameter(p,'edge',nan);
addParameter(p,'label',nan);
parse(p,fun,data,varargin{:});
edge = p.Results.edge;
label = p.Results.label;
data = p.Results.data;
fun = p.Results.func;
assert(all(~isnan(edge))||all(~isnan(label)),'please provide the edge or label!');
S.type = '()';

if ~isnan(edge)
    idata = cell(length(edge)-1,1);
    S.subs = [{edge(1):edge(2)};repmat({':'},ndims(data)-1,1)];
    idata{1} = (fun(subsref(data,S)));
    for i=2:length(edge)-1
        S.subs = [{edge(i)+1:edge(i+1)};repmat({':'},ndims(data)-1,1)];
        idata{i} = (fun(subsref(data,S)));
    end
    idata = cat(1,idata{:});
else
end
end

