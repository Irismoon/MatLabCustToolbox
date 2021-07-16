function [outputArg1,outputArg2] = getsubfolders(parentpath,level)
search_level = 0;
currentpath = '';
while search_level<level
    search_level = search_level+1;
    folderstruct = dir(fullfile(parentpath,currentpath));
    id = [folderstruct.isdir];
    folderstruct(~id) = [];
    for i=1:length(folderstruct)
        folderstruct(i).folder,folderstruct(i).name
    end
end
end

