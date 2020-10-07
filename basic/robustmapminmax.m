function Y = robustmapminmax(X,dim,varargin)
%Y = robustmapminmax(X,dim,varargin)
%dim: 1 or 2
%varargin{1}:min, varargin{2}:max
P = inputParser;
addRequired(P,'X',@isnumeric);
addRequired(P,'dim',@isnumeric);
addOptional(P,'ymin',-1,@isnumeric);
addOptional(P,'ymax',1,@isnumeric);
parse(P,X,dim,varargin{:});
X = P.Results.X;
dim = P.Results.dim;
ymin = P.Results.ymin;
ymax = P.Results.ymax;
if abs(dim-1)<1e-6
    Y = mapminmax(X',ymin,ymax)';
else
    Y = mapminmax(X,ymin,ymax);
end
end

