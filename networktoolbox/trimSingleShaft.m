function A = trimSingleShaft(pn,A,actchn)
%trim the connection on single shaft due to local reference
%trim when: L1-L2-L3, don't keep anyone
%A: connection matrix, chn x chn
%name: chn x 1,
%A could be 1.an uncomplete chnxchn connection matrix, with name maybe
%A1,A2,A3,A5,A7...;2.an edge list:[1 2;1 3;...] with name A1,A2,A3
%
load(env.get(pn,'elecinfo'));
name = elecinfo.name(actchn);
sz = size(A);
if ismatrix(A)
    sz(3) = 1;
end
[label,index] = sepShaft(name);%shaft label and index of each contact;
ulabel = unique(label,'stable');
reqChnNo = 0;
for i=1:length(ulabel)%for each shaft
    reqIdx = index(label==ulabel(i));%e.g.1 2 5 7
    orgIdx = pn2Shaft(pn,ulabel(i));%e.g.1 2 3 4 5 7
    [~,embIdx] = ismember(reqIdx,orgIdx);
    reqChnNo = reqChnNo+length(reqIdx);%the to be changed chns
    %make up mask: 1.the original reference sequence;2.take the
    %requested sequence
    orgChnNo = length(orgIdx);
    orgMask = ones(orgChnNo);%6*6
    idxtmp = sub2ind([orgChnNo orgChnNo],1:orgChnNo-1,1:orgChnNo-1);%
    idxtmp = [idxtmp+1 idxtmp(1:end-1)+2];
    orgMask(idxtmp) = nan;%trim according to reference order
    reqMask = orgMask(embIdx,embIdx);%retains the requested trim
    %trim
    idxtmp = length(reqIdx)-1:-1:0;%e.g.4£º0
    A(reqChnNo-idxtmp,reqChnNo-idxtmp,:) = ...
        A(reqChnNo-idxtmp,reqChnNo-idxtmp,:).*repmat(reqMask,1,1,sz(3));
end
end

