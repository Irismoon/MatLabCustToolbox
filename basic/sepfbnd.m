function [fband,fbndNo,fbinnew] = sepfbnd(f)
%[fband,fbndNo,fbinnew] = sepfbnd(f)
%this function is to separate the frequency vector f into several frequency
%band
%output:
%fband: f x 1 vector, e.g.[nan nan 1 1 2 2 4 4 nan 5 5]
%fbndNo: frequency band x 1, e.g. 1 2 4 5
fbin = [10 25 55 65 100 250];
fbinnew = [10 25;25 55;65 100;100 250];
fband = basic.change_row_to_col(discretize(f,fbin),1);
fband(fband==3) = nan;%ignore the 55-65Hz
fbndNo = unique(fband);
fbndNo = fbndNo(~isnan(fbndNo))';%1 2 4 5
end

