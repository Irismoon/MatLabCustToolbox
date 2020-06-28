function X=sort_var(X,varargin)
%sort_var(X,varargin)
%example varargin:2 5
%this function simply permute the X based on our limite knowledge of it.
%for example, mostly our data is chn x chn x  f x acttype x phase, but we
%usually cannot remember it's acttype x phase or phase x acttype, but we
%know the value of phase/acttype, e.g. numphase = 4,acttype = 5, so
%sort_var(X,4,5) will return X in form of chn x chn x f x phase x acttype.

sz = size(X);

idx = cellfun(@(x) find(x==sz),varargin);
X = permute(X,[1 2 3 idx]);
end

