inc = {'cvholdout','alpha','lambda','nt1','nd1','h1','f1'};
MeanBy = {'cvholdout'};
diff = @(h,m,f,n) (double(h)/double(m)) - (double(f)/double(n));
njobs = 10;
ndigits = nnz(njobs > 10.^(0:8));
fmt = sprintf('%%0%dd',ndigits);
for i = 1:njobs
  d = sprintf(fmt,i-1);
  p = fullfile(d,'results.mat');
  load(p,'results');
  fn = fieldnames(results);
  z = ~ismember(fn, inc);
  r = struct2table(rmfield(results, fn(z)));
  r.diff = rowfun(diff, r, 'InputVariables', {'h1','nt1','f1','nd1'}, 'OutputFormat', 'uniform');
  r.h1 = [];
  r.nt1 = [];
  r.f1 = [];
  r.nd1 = [];
  r = varfun(@mean,r,'GroupingVariables', MeanBy);
  
  if i > 1
    a = ix(i-1) + 1;
    b = ix(i);
    R(a:b,:) = r;
  else
    nrow = size(r,1);
    R = r;
    R((nrow*njobs)+1,:) = r(1,:);
    R((nrow*njobs)+1,:) = [];
    ix = (1:njobs)*nrow;
  end
  
end
writetable(R, 'soslasso_face_lFP_tune.csv');