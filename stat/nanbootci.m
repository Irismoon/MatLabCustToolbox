function ci = nanbootci(nboot,fh,x)
%ci = nanbootci(nboot,fh,x)
%to solve the cases not included in built-in bootci:
%   1. x is empty, return nan;
%   2.x is all nan, return nan;
%   3.x is scalar rather than vector, return nan;
%fh:function handle
%x: samples x variables
[nsample,nv] = size(x);
if nv==0
    ci = [nan;nan];
else
    ci = zeros(2,nv);
    parfor i = 1:nv
        tmp = x(:,i);
        tmp = tmp(~isnan(tmp));
        if length(tmp)>1
            ci(:,i) = bootci(nboot,fh,tmp);
        else
            ci(:,i) = [nan;nan];
        end
    end
end

