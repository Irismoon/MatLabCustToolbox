function x = nanunique(x)
x = unique(x(~isnan(x)));
end

