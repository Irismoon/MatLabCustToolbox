function [startIdx,numw] = win_segment(tslen,winlen)
%function startIdx = win_segment(tslen,winlen)
%startIdx: ts x win
numw = fix(tslen/winlen);
startIdx = (0:numw-1)*winlen + (1:winlen)';
end

