function varargout = sameAssign(value,k,sz)
varargout = cell(k,1);
for i=1:k
    varargout{i} = ones(sz)*value;
end
end

