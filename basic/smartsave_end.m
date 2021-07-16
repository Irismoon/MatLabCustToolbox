function [outputArg1,outputArg2] = smartsave_end(path,varlist,C)
new_path = [{path},varlist];
new_path = strjoin(new_path,'_');
movefile([path '.mat'],[new_path '.mat']);
S = whos('-file',new_path);
if exist([path '.txt'],'file')
    movefile([path '.txt'],[new_path '.txt'],'f');
end
writefileId = fopen([new_path '.txt'],'w');
for k=1:length(S)
    tline_new = [S(k).name ' ' mat2str(S(k).size) ' ' S(k).class '\n'];
    fprintf(writefileId,tline_new);
end
fprintf(writefileId,[C.codefile,'\n']);
fprintf(writefileId,[C.gitInfo.branch,'\n']);
fprintf(writefileId,[C.gitInfo.hash,'\n']);
fprintf(writefileId,[C.comment,'\n']);
fprintf(writefileId,[char(C.time),'\n']);
fclose(writefileId);