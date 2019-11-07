function [outputArg1,outputArg2] = journalTitleCheck()
%make journal title consistent , i.e. uppercase the first letter
fid = fopen(fullfile(env.get('code'),'MatLabCustToolbox','writing','ref.txt'));
while ~feof(fid)
    line = fgetl(fid);
    if ~isempty(regexp(line,'journal', 'once'))
        y = strsplit(line,{'=','{','}'});
        [~,id] = max(cellfun(@length,y));
        y{id} = upperFirst(y{id},' ','robust');
        line = ['journal = {' y{id} '},'];%how to renew a line in textfile
    end
end
fclose(fid);
end

