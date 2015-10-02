function out = GP(X,y,S,option)
%% Do GP for input variables and learning target
% X: 2-D
% y: 1-D

ns1 = option.gridsize;
ns2 = option.gridsize;



covfunc = @covSEard; 
likfunc = @likGauss;

hyp.cov = [0; 0; 0];
hyp.lik = log(0.1);
hyp = minimize(hyp, @gp, -500, @infExact, [], covfunc, likfunc, X, y);
%exp(hyp.cov)
%exp(hyp.lik)

[est, var] = gp(hyp, @infExact, [], covfunc, likfunc, X, y, S);

out.meanest = reshape(est, ns2, ns1);
out.varest = reshape(var, ns2, ns1);
out.hyp = hyp;

end