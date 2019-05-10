function distcmp(cor,param)
figure('Name',[param.theme '-Similarity of (node bw distances) under twoconds']),
bar(cor);
title([param.theme '-Similarity of (node bw distances) under twoconds']);
xlabel('frequency band');ylabel('Pearson Corrcoef');
end

