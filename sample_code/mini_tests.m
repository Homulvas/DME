% Script to try Orange problem


clop_dir='Z:\user On My Mac\Isabelle\Projects\Challenges\ChallengeBook\CLOP';
addpath(clop_dir);
use_spider_clop;

data_dir=pwd; % Directory name where the data are
SMtr=load_orange(data_dir, 1, 1);
SMte=load_orange(data_dir, 0, 1);

my_prepro=chain({missing, rmconst, standardize});
[Dtr, my_prepro]=train(my_prepro, data(SMtr.X, SMtr.churn));
Dte=test(my_prepro, data(SMte.X, SMte.churn));

my_model=chain({subsample({'p_max=20000', 'balance=1'}), naive});
[tr_output, trained_model]=train(my_model, Dtr);
tr_output=test(trained_model, Dtr);
te_output=test(trained_model, Dte);
auc(tr_output)
auc(te_output)

my_prepro=chain({code_categorical([191:230]), missing, rmconst, standardize});
[Dtr, my_prepro]=train(my_prepro, data(SMtr.X, SMtr.churn));
Dte=test(my_prepro, data(SMte.X, SMte.churn));

%my_model=chain({active(kridge, 'p_max=20000')});
% change these to balance the samples
my_model=chain({subsample({'p_max=20000', 'balance=1'}), kridge});

if 1==2
my_prepro2=chain({missing, rmconst, standardize});
[Dtr2, my_prepro2]=train(my_prepro2, data(SMtr.X(:, 1:190), SMtr.churn));
Dte2=test(my_prepro2, data(SMte.X(:, 1:190), SMte.churn));
end

%my_model=active(chain({kridge('balance=1'), bias}), {'p_max=20000', 'balance=1'});
my_model={};
for k=1:10
    my_model{k}=chain({subsample({'p_max=20000', 'balance=1'}), kridge, bias});
end
my_big_model=ensemble(my_model);

%save('Dprepro', 'Dtr2', 'Dte2');
%load('Dprepro');
my_model=chain({s2n('w_min=0.1'), subsample({'p_max=20000', 'balance=1'}), poly_feat, kridge});
my_model=chain({s2n('w_min=0.1'), subsample({'p_max=20000', 'balance=1'}), poly_feat, naive});
[tr_output, trained_model]=train(my_model, Dtr2);

tr_output=test(trained_model, Dtr2);
te_output=test(trained_model, Dte2);

auc(tr_output)
auc(te_output)

%save('logitboost', 'tr_output', 'te_output');
% Cheating filter:
%[dd, mm]=train(s2n, Dtr);
%[dt, mt]=train(s2n, Dte);
%idx_good=(find((abs(mm.W-mt.W))<0.1));
%save('idx_good', 'idx_good');

load('idx_good');

%idx_good=1:173;
Dtr2=data(Dtr.X(:, idx_good), Dtr.Y);
Dte2=data(Dte.X(:, idx_good), Dte.Y);




% Score results:
basedir='Z:\user On My Mac\Isabelle\Projects\Challenges\KDDcup09\';
resudir=[basedir 'Results'];
truthdir=[basedir 'Data\Labels'];
scoredir=[basedir 'Score'];

simple_score(resudir, truthdir, scoredir);


