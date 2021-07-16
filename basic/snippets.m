%common function snippets
%find all files with same format
folderpath = fullfile(getpath('neural activity','image segmentation'),'ZBB anatomy','*.tif');
fileinfo = dir(folderpath);
t = arrayfun(@(i) regexp(fileinfo(i).name,'\d{2}','match'),1:length(fileinfo),'un',0);
t = cellfun(@(x) str2double(x{1}(5:6)),t);
[t,I] = sort(t,'ascend');
fileinfo = fileinfo(I);
fileinfo(1).folder,fileinfo(1).name

%remove . from found folder/file
dirResult = dir(fullpath);
dirResult(arrayfun(@(i) ismember(dirResult(i).name,{'.','..'}),1:length(dirResult))) = [];


%read stacked images
imag = arrayfun(@(iframe) imread(imagpath,iframe),1:length(imfinfo(imagpath));
imwrite(imag{1},writerpath);imwrite(imag{1},writerpath,'WriteMode','append');

%video
V = VideoReader(filepath);
writer = VideoWriter(fullfile(getpath('behavior',sessionID,fishID),'low_unalign.avi'));
open(writer);
while hasFrame(V)
    writeVideo(writer,readFrame(V));
end
%or read(v,[start end]) could return the required frames
close(writer);
frame_plot = getframe(gcf);
frame_plot = frame_plot.cdata;
frame_out(1:hplot,1:wplot,:) = frame_plot;
writeVideo(writer,frame_out);

%display number under non-scientific format/非科学计数法
sprintf('%0.5f',number)

%write to txt
readfileId = fopen('test.txt','r');
writefileId = fopen('output.txt','w');
while ~feof(readfileId)
tline = fgets(readfileId);
str = strsplit(tline,'=');
tline_new = [str{1} '= nan'']);\n'];
fprintf(writefileId,tline_new);
end

%%
%graphics pbject buttondown callback
plot(x,'ButtonDownFcn',@(src,evt) displaytext(src,evt,gca,id))
function displaytext(src,eventdata,axeshandle,id)
    [y,I] = max(abs(src.YData));
    x = src.XData(I);
    text(axeshandle,x,y,num2str(id));
    title(gca,num2str(id));
%     src.Color = 'red';
end
%%
%regexp
regexp(name,'_(\d+)dpf','tokens')% to look for patterns like _10dpf
%or
regexp(name,'_[0-9]+dpf','tokens')
%%
%pipeline of hierarchical clustering
Z = linkage(data,'average');
[~,~,outperm] = dendrogram(Z,'labels',label);
label = cluster(Z,'Cutoff',0.150,'criterion','distance');
%%
%transparent gscatter
h = gscatter(x,y,group);
set(h(1),'Marker','o','MarkerEdgeColor','none','MarkerFaceColor','r','MarkerSize',5);
set(h(1).MarkerHandle,'FaceColorType','truecoloralpha','FaceColorData',uint8([200;0;0;40]));
%% boxplot 
h = iosr.statistics.boxPlot(unequalcell2mat(tmp),'theme','colorboxes');%tmp is a nx*ny cell array
%%
xline(1,'r--');
xline(1,'Color',c,'LineWidth',2.5);
%%
%quicker intersection function specifically for two column matrix and
%elements are positive integers
function C = my_simple_intersect(A,B)
%function C = my_simple_intersect(A,B)
%C is the number of intersection
if ~isempty(A)&&~isempty(B)
    P1 = zeros(1,max(max(A(:,1)),max(B(:,1))));
    P1(A(:,1)) = 1;
    
    P2 = zeros(1,max(max(A(:,2)),max(B(:,2))));
    P2(A(:,2)) = 1;
    
    C = nnz(P1(B(:,1))&P2(B(:,2)));
else
    C = 0;
end
end