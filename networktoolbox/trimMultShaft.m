function A = trimMultShaft(pn,A,actchn)
% A = trimMultShaft(pn,A,name)
%to trim the case where L1 connects to A1,A2,and A3
load(env.get(pn,'elecinfo'));
name = elecinfo.name(actchn);
[No,~,Nwin] = size(A);
%put £Á two sided,i.e. symmetrical
mask = tril(true(No));
A(isnan(A))=-1;
A = A.*repmat(mask,1,1,size(A,3));
A = permute(A,[2 1 3])+A;
A(A<0) = nan;
%find the adjacent contacts
[label,index] = sepShaft(name);
ulabel = unique(label,'stable');
clust = nan(No,1);
for i=1:length(ulabel)
    bigfrmIdx = find(label == ulabel(i));%20 21 22 23 24 25 26
    smallfrmIdx = index(bigfrmIdx);%1 3 4 5 7 8 9
    idxtmp = bigfrmIdx(find(diff(smallfrmIdx)==1));%21 22 24 25
    marker = 1;
    for j=1:length(idxtmp)
        if j>1 && idxtmp(j)-idxtmp(j-1) >1
            marker = marker+1;
        end
        clust(idxtmp(j):idxtmp(j)+1) = marker;%the adjacent contact is assigned same number
    end
end
uclust = unique(clust(~isnan(clust)),'stable');

% for i=1:No%for each contact
%     a = A(:,i);
%     for j=1:length(uclust)
%         orgIdx = find(clust == uclust(j));%the index under the whole frame
%         reqIdx = find(a(orgIdx) < max(a(orgIdx)));%the chn under the local frame
%         a(orgIdx(reqIdx)) = nan;
%     end
%     A(:,i) = a;
% end
%for each chn who connect to several adjacent contacts, only keep the
%largest one
clust = repmat(clust,1,No,Nwin);
for j=1:length(uclust)
    orgIdx = find(clust == uclust(j));%the index under the whole frame
    Atmp = reshape(A(orgIdx),[],No,Nwin);%
    Atmp(Atmp<max(Atmp,[],1)) = nan;
    A(orgIdx) = Atmp;
end
mask = triu(true(No));
A(repmat(mask,1,1,Nwin)) = nan;