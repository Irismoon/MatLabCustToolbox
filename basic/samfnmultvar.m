function [varargout] = samfnmultvar(fn,varargin)
%[varargout] = samfnmultvar(fn,varargin)
tf = isa(fn,'function_handle');
assert(tf,'please provide a function handle!')
varargout = cellfun(@(x) feval(fn,x),varargin,'un',0);
end

