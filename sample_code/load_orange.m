function D=load_orange(dn, tr_te, sm_lg)
% D=load_orange(dn, tr_te, sm_lg)
% Load the Orange dataset from raw data found in directory named dn.
% tr_te=1: load training data; otherwise load test data
% sm_lg=1: load small data; otherwise load large data
% Assumes all data are in subdirectories of dir called
% orange_large and orange_small
% Returns a data structure D.

if sm_lg
    dn=[dn '/orange_small/orange_small_'];
else
    dn=[dn '/orange_large/orange_large_'];
end

dtr=[dn 'train'];
dte=[dn 'test'];
if tr_te
    dn=dtr;
else
    dn=dte;
end

if sm_lg
    if ~(exist([dn '.mat'])==2) 
        % Convert the data to numeric and save it in Matlab format
        fprintf('Converting data, be patient!!!!\n');
        fprintf('Training data categorical variables\n');
        Xtxt_tr=load_text([dtr '.data'], 50000, 40, 1);
        fprintf('Test data categorical variables\n');
        Xtxt_te=load_text([dte '.data'], 50000, 40, 1);
        fprintf('Converting categorical to numerical\n');
        [Xnum2_tr,Xnum2_te]=convert2num(Xtxt_tr, Xtxt_te);
        fprintf('Training data numerical variables\n');
        Xnum=load_text([dtr '.data'], 50000, 190, -1);
        X=[Xnum,Xnum2_tr];
        save([dtr '.mat'], 'X');
        fprintf('Test data numerical variables\n');
        Xnum=load_text([dte '.data'], 50000, 190, -1);
        X=[Xnum,Xnum2_te];
        save([dte '.mat'], 'X');
    end 
    load([dn '.mat']); D.X=X;
    D.toy=load_numeric([dn '_toy.labels']);
    D.churn=load_numeric([dn '_churn.labels']);
    D.appetency=load_numeric([dn '_appetency.labels']);
    D.upselling=load_numeric([dn '_upselling.labels']);
    if strfind(dn, 'test'), 
        D.valid_idx=find(load_numeric([dn '_subset.sel'])==1);
    end
end

