function [color,symbol] = getColorSymbol(n)
k = 13;
defaultColor = [brewermap(9,'Set1');rgb({'magenta','black','skyblue','blue'})];
defaultSymbol = {'.','+','o'};
% defaultSymbol = {'<','>'};
tail = mod(n,k);
mult = floor(n/k);
color = [repmat(defaultColor,mult,1);defaultColor(1:tail,:)];
symbol = [reshape(repmat(defaultSymbol(1:mult),k,1),[],1);repmat(defaultSymbol(mult+1),tail,1)];
symbol = cat(1,symbol{:});
end

