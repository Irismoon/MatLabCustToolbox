function z = nanzscore(x)
%function z = nanzscore(x)
%x: nasample x nvariable
[nsample,nv] = size(x);
z = zeros(nsample,nv);
for i=1:nv
    tmp = x(:,i);
    idx = isnan(tmp);
    tmp2 = tmp(~idx);
    tmp(~idx) = zscore(tmp2);
    z(:,i) = tmp;
end
end

