function [ y ] = robustfiltfilt(b,a,x)
if isa(x,'single')
    x = double(x);
end
y = filtfilt(b,a,x);
