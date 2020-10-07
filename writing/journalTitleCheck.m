function [outputArg1,outputArg2] = journalTitleCheck()
%make journal title consistent , i.e. uppercase the first letter
fidr = fopen(fullfile(env.get('code'),'MatLabCustToolbox','writing','ref.txt'));
fidw = fopen(fullfile(env.get('code'),'MatLabCustToolbox','writing','nref.txt'),'w');
while ~feof(fidr)
    line = fgetl(fidr);
%     if ~isempty(regexp(line,'journal', 'once'))
%         y = strsplit(line,{'=','{','}'});
%         [~,id] = max(cellfun(@length,y));
%         y{id} = upperFirst(y{id},' ','robust');
%         line = ['journal = {' y{id} '},'];%how to renew a line in textfile
    if ~isempty(regexp(line,'title', 'once'))
%         y = strsplit(line,'=');
        y = regexp(line,'{','once');
        y = line(y+1:end);
        title = [upper(y(1)) lower(y(2:end))];
        line = [' title = {' title];
    end
    fprintf(fidw,sprintf([line '\n']));
end
fclose('all');
end
%Note: you still need to fine tune the 
