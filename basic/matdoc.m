function S = matdoc(varargin)
%S = matdoc(varargin)
%this function is to document the matfile, i.e. document the parameters for
%the file like from which codefile the matfile is generated, date and time,
%git info(to know the code version when this dataset is generated.)
%and so on
%the varargin is recommended to record here, too, since it sometimes also contains necessary.
%parameters
S.time = datetime('now');
st = dbstack('-completenames',1);%omit first frame
S.codefile = st(1).file;
S.gitInfo = getGitInfo;
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

