function [del_idx] = find_unequal_element(A,B)
%function [del_idx] = find_unequal_element(A,B)
%A is short one, B is longer one
len_short = min(length(A),length(B));
len_long = max(length(A),length(B));

ori_B = B;
del_idx = zeros(len_long-len_short,1);
k=0;
for i=1:len_short
    while A(i)~=B(i)
        k=k+1;
        del_idx(k) = i+nnz(del_idx);
        B(i) = [];
    end
end
ori_B(del_idx)=[];
assert(isequal(A,ori_B),'unequal length at final!');
end

