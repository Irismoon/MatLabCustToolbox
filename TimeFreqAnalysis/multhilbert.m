function Y = multhilbert(X)
sz = size(X);
Y = zeros(sz);
assert(length(sz)<=3,'only support 3 dim now!')
% ndgrid(eval(sz(3:end)))
if length(sz)>2
    for i=1:sz(3)
        Y(:,:,i) = hilbert(X(:,:,i));
    end
else
    Y = hilbert(X);
end

