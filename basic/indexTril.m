function index = indexTril(sz)
index = sz*(0:sz-1) + (1:sz)';%sz x sz
mask = tril(true(sz),-1);
index = mask.*index;
index = index(index>0);
end

