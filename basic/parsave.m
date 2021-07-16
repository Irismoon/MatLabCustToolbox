function parsave(filename,value,name)
%function parsave(filename,value,name)
for i=1:length(name)
    eval([name{i} '= value{i};']);
end

if exist(filename,'file')
    for i=1:length(name)
        save(filename,name{i},'-append');
    end
else
    save(filename,name{1});
    for i=2:length(name)
        save(filename,name{i},'-append');
    end
end

