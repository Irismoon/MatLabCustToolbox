function filepath = smartsave_start(filepath)
fileinfo = dir([filepath '*.mat']);
if ~isempty(fileinfo)
filepath = fullfile(fileinfo.folder,fileinfo.name);
filepath = filepath(1:end-4);
end
end