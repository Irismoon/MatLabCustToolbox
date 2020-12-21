function yfit = regf(Xtrain,ytrain,Xtest)
mdl = stepwiselm(Xtrain,ytrain);
yfit = predict(mdl,Xtest);
end

