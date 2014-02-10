function [param, idx_out]=lambda_train(X_train, Y_train, idx_in)
%[param, idx_out]=lambda_train(X_train, Y_train, idx_in)
% This simple but efficient two-class linear classifier 
% of the type Y_hat=X*W'+b was invented by Golub et al.
% Inputs:
% X_train -- Training data matrix of dim (num examples, num features).
% Y_train -- Training output matrix of dim (num examples, 1).
% idx_in -- Indices of the subset of features selected by preprocessing.
% Returns:
% param -- a structure with two elements
% param.W -- Weight vector of dim (1, num features)
% param.b -- Bias value.
% idx_out -- Indices of the subset of features effectively 
%            used/selected by training.

% Isabelle Guyon -- September 2003 -- isabelle@clopinet.com

if nargin<3, idx_in=1:size(X_train,2); end

X=X_train(:,idx_in);
Posidx=find(Y_train>0);
Negidx=find(Y_train<0);
Mu1=mean(X(Posidx,:));
Mu2=mean(X(Negidx,:));
Sigma1=std(X(Posidx,:),1);
Sigma2=std(X(Negidx,:),1);
Sigma1(find(Sigma1==0))=eps;
Sigma2(find(Sigma2==0))=eps;
param.W=(Mu1-Mu2)./(Sigma1+Sigma2);
B=(Mu1+Mu2)/2;
param.b=-param.W*B';
idx_out=idx_in;