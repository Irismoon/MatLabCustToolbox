function y = divisor(x)
%function y = divisor(x)
%it finds out all divisor of x
%i.e., x的所有约数
assert(mod(x,1)==0,'x must be an integer!');
a = 1:x;
y = a(mod(x,a)==0);
end

