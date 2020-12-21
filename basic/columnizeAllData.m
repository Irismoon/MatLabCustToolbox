%process all data into column data
S = whos;
numVar = length(S);
for i=1:numVar
    if S(i).size(1)==1 && length(S(i).size)==2
        try
        eval([S(i).name '= row2col(' S(i).name ',1);']);
        catch ME
            disp([S(i).name ' cannot be transposed']);
            continue
        end
    end
end