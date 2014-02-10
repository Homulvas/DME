function data_stat(Dtr, Dte, cate_list, fp)
% data_stat(Dtr, Dte, cate_list, fp)
% Dtr and Dte are training and test data structures
% fp is a file descriptor
% Extract data statistics

% Isabelle Guyon -- isabelle@clopinet.com -- March 2009

if nargin<4, fp=2; end

if ~isnumeric(Dtr.X), return; end

% Collect statistics on training data
[vartype, sparsity, tartype, valnum, balance, n, p]=stats(Dtr, -1);
num_list=setdiff([1:n], cate_list);
cate_num=length(cate_list);
numeric_num=n-cate_num;
num_missing=length(find(isnan(Dtr.X(:,num_list))))+length(find(Dtr.X(:,cate_list)==0));


fprintf(fp, '\nDataset\tVar. num. (numeric+categorical)\tfrac. missing\tY Type (c)\tPat. num.\t Frac. pos.\tPat/Var\n');
fprintf(fp, 'Training\t%d (%d+%d)\t%5.2f\t%s (%d)\t%d\t%s\t%5.2f\n', ...
         n, numeric_num, cate_num, num_missing/(n*p), tartype, valnum, p, balance, p/n); 

% Collect statistics on test data
if ~isempty(Dte)
    [vartype, sparsity, tartype, valnum, balance, n, p]=stats(Dte, -1);
    num_missing=length(find(isnan(Dte.X(:,num_list))))+length(find(Dte.X(:,cate_list)==0));
fprintf(fp, 'Test\t%d (%d+%d)\t%5.2f\t%s (%d)\t%d\t%s\t%5.2f\n', ...
         n, numeric_num, cate_num, num_missing/(n*p), tartype, valnum, p, balance, p/n); end
