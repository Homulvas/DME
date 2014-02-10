function [Xnum2_tr, Xnum2_te]=convert2num(Xtxt_tr, Xtxt_te)
%[Xnum2_tr,Xnum2_te]=convert2num(Xtxt_tr, Xtxt_te)
% Convert texttual categorical variables to numeric categorical variables.

% Isabelle Guyon -- Feb. 2009

[ptr, ntr]=size(Xtxt_tr);
[pte, nte]=size(Xtxt_te);
Xnum2_tr=zeros(ptr, ntr);
Xnum2_te=zeros(pte, nte);

Xtot=[Xtxt_tr; Xtxt_te];

fprintf('Finding unique categories\n');
[p,n]=size(Xtot);
for k=1:n, D{k}=unique(Xtot(:,k)); end

fprintf('Formatting training data\n');
for j=1:n, 
    fprintf('%d ', j);
    d=D{j};
    if ~isempty(d{1})
        d={'' d{:}};
    end
    for k=1:length(d)
        i=strmatch(d{k}, Xtxt_tr(:,j));
        Xnum2_tr(i, j)=k-1; % 0 will be for missing values
    end
end

fprintf('\nFormatting test data\n');
for j=1:n, 
    fprintf('%d ', j);
    d=D{j};
    if ~isempty(d{1})
        d={'' d{:}};
    end
    for k=1:length(d)
        i=strmatch(d{k}, Xtxt_te(:,j));
        Xnum2_te(i, j)=k-1; % 0 will be for missing values
    end
end

fprintf('\n');

