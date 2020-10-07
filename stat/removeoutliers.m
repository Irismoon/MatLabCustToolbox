function x = removeoutliers(x,range)
thld = quantile(x,range);
x(x>=thld(2) | x<=thld(1)) = nan;
end

