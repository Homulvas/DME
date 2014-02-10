function Y_resu = lambda_predict(X_test, param, idx_feat)
%Y_resu = lambda_predict(X_test, param, idx_feat)
% Make classification predictions with the lambda method.
% Inputs:
% X_test -- Test data matrix of dim (num test examples, num features).
% param -- Classifier parameters, see lambda_trainer.
% idx_feat -- Indices of the features selected.
% Returns:
% Y_resu -- Discriminant values.

% Isabelle Guyon -- September 2003 -- isabelle@clopinet.com

[p, n]=size(X_test);
if nargin<3, idx_feat=1:n; end

Y_resu=X_test(:,idx_feat)*param.W'+param.b;


