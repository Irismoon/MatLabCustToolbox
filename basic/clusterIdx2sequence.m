function clusterAssignment = clusterIdx2sequence(clusterAssignment)
label = unique(clusterAssignment(~isnan(clusterAssignment)));
for i=1:length(label)
    clusterAssignment(clusterAssignment==label(i)) = i;
end
end

