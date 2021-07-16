function [f,p1] = smartFFT(X,fs)
% function [f,p1] = smartFFT(X,fs)
L = size(X,1);
L = 2^nextpow2(L);
Y = fft([X;zeros(L-size(X,1),size(X,2))]);
p2 = abs(Y/L);
p1 = p2(1:L/2+1,:);
p1(2:end-1,:) = 2*p1(2:end-1,:);
f = fs*(0:(L/2))/L;

end

