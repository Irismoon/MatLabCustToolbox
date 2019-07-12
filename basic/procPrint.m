function [outputArg1,outputArg2] = procPrint(chn,chnNo,mark)
if mod(chn,mark)==0
    fprintf(['chn: ' num2str(chn) '...Remaining: ' num2str(chnNo-chn) '\n']);
end
end

