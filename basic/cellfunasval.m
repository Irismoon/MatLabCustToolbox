function [x] = cellfunasval(x,y,z)
%[x] = cellfunasval(x,y,z), x{i}(y{i}) = z{i};
%this function is to assign value for each cell in x 
if iscell(x)
numcell = length(x);
if isa(x{1},'numeric')%a matrix
for i = 1:numcell
    x{i}(y{i}) = z{i};
end
elseif isa(x{1},'graph')
    for i = 1:numcell
        eval(['x{i}' y{i} '= z{i}']);
    end
else
    error('please provide an object of valid class!')
end
elseif isstruct(x)
   fldname = fieldnames(x);
   for i=1:length(fldname)
       x.(fldname{i}) = subsasgn(x.(fldname{i}),y,z.(fldname{i}));
   end
end
end

