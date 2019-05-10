function conncompcmp(cor,param)
figure('Name',[param.theme '-Similarity of (Nodes composition of connected component) under twocond']),
bar(cor);
xlabel('frequency band');ylabel('Pearson Corrcoef');
title([param.theme '-Similarity of (Nodes composition of conncomp) under twocond']);
end

