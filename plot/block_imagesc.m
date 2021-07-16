function [outputArg1,outputArg2] = block_imagesc(X,block)
%function [outputArg1,outputArg2] = block_imagesc(X,block)
%block is the place you want a line
figure,
imagesc(X);
hold on;
arrayfun(@(i) xline(i,'k--','LineWidth',1),col2row(block,1),'un',0);

arrayfun(@(i) yline(i,'k--','LineWidth',1),col2row(block,1),'un',0);
end

