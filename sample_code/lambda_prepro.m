function [X, param]=lambda_prepro(X, param)
%[X, param]=lambda_prepro(X, param)
% Fill missing values with median.
% Remove constant features.
% param: preprocesing parameter structure
% param.med: median values to fill in missing values
% param.idx: index of non-constant features
% param.mu: feature means
% param.std: feature standard dev

% Isabelle Guyon -- isabelle@clopinet.com -- March 2009

if nargin<2, param.med=[]; param.idx=[]; param.mu=[]; param.std=[];end
[p,n]=size(X);

% Fill in mising values
if isempty(param.med)
    for k=1:n
        non_missing=find(~isnan(X(:,k)));
        if isempty(non_missing)
            %warning('One column entirely missing');
            param.med(k)=0;
        else
            param.med(k)=median(X(non_missing,k), 1);
        end
    end
end

for k=1:n
    missing=find(isnan(X(:,k)));
    X(missing,k)=param.med(k);
end

% Remove constant features
if isempty(param.idx)
    param.idx=find(any(X(ones(size(X,1),1),:)~=X));
end

X=X(:, param.idx);

% Standardize
[X, param.mu, param.std]=stand(X, param.mu, param.std);

function [X, M, S]=stand(X, M, S)

if isempty(M), M=mean(X); end
if isempty(S), S=std(X, 1, 1); S(find(S==0))=1; end
n=size(X,1);
X=X-M(ones(n,1),:);
X=X./S(ones(n,1),:);

