function [Cout] = squareformX(C,flag)
%Input:
%C: (numChn-1) x 1 cell array; inside each cell, f x taper x trial x chn, but chn
%is different in different cells
%numchn: num of channels
%flag: positive or negative
%output:
%Cout: f x taper x trial x chn x chn
numChn = length(C);
sizetmp = ndims(C{1});
[sizeCpre,ia,~] = intersect(arrayfun(@(dim)size(C{1},dim),1:sizetmp-1),arrayfun(@(dim)size(C{2},dim),1:sizetmp),'stable');% f x taper x trial
if length(ia)==1 && ia==2 %column vector
    C = cellfun(@transpose,C,'un',0);
end
Cout = zeros([sizeCpre numChn numChn]);
Sout.type = '()';
Sout.subs = repmat({':'},1,sizetmp+1);
Sin(1).type = '{}';
Sin(2).type = '()';
Sin(2).subs = repmat({':'},1,sizetmp);
S.type = '()';
S.subs = repmat({':'},1,sizetmp+1);
for i = 1:numChn
    Sout.subs{end-1} = i;Sout.subs{end} = i;
    Cout = subsasgn(Cout,Sout,ones(sizeCpre));
    %     Cout(:,:,:,i,i) = ones(sizeCpre);
    for j = i+1:numChn
        Sout.subs{end-1} = j;Sout.subs{end} = i;
        Sin(1).subs = {i};
        Sin(2).subs{end} = j-i;
        Cout = subsasgn(Cout,Sout,subsref(C,Sin));
        %         Cout(:,:,:,j,i) = C{i}(:,:,:,j-i);
        if flag == 'positive'
            Sout.subs{end-1} = i;Sout.subs{end} = j;
            S.subs{end-1} = j;S.subs{end} = i;
            Cout = subsasgn(Cout,Sout,subsref(Cout,S));
            %             Cout(:,:,:,i,j) = Cout(:,:,:,j,i);
        elseif flag == 'negative'
            Sout.subs{end-1} = i;Sout.subs{end} = j;
            S.subs{end-1} = j;S.subs{end} = i;
            Cout = subsasgn(Cout,Sout,-subsref(Cout,S));
        else
            assert('check the flag acceptable value');
            
        end
    end
end
end

