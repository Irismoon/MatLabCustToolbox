function S = matdoc(varargin)
%S = matdoc(varargin)
%this function is to document the matfile, i.e. document the parameters for
%the file like from which codefile the matfile is generated, date and time,
%and so on
S.time = datetime('now');
st = dbstack('-completenames',1);%omit first frame
S.codefile = st(1).file;
len = length(varargin);
idx = 1:len;
if mod(len,2)==0
    for i = 1:len/2
%         eval(['S.' varargin{i*2-1} '=' ]) = varargin{i*2};
        S.(varargin{i*2-1}) = varargin{i*2};
    end
else
    error('Must provide name and value both!');
end
end

