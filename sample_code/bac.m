function [acc, sigma]=bac(Output, Target)
%[acc, sigma]=bac(Output, Target)
% Compute a "balanced" accuracy as the average
% of the accuracy of positive examples (sensitivity) and the
% accuracy of positive examples (specificity).
% Inputs:
% Output    --  Classifier outputs in columns of dim (num pattern, num tries)
% Target    -- +-1 target values of dim size(Output,1).
% Returns:
% acc    -- Balanced accuracy.
% sigma -- Error bar.

% Isabelle Guyon -- December 2007 -- isabelle@clopinet.com

warning off

[nn,pp]=size(Output);
if nn==1
    Output=Output';
    Target=Target';
end

acc=[];
sensitivity=[];
specificity=[];
sigma=[];

Output=full(Output);
Target=full(Target);

pos_idx=find(Target>0);
neg_idx=find(Target<0);

if isempty(pos_idx)
    sensitivity=0.5;
else
    sensitivity=mean(Output(pos_idx,:)>=0);
end
if isempty(neg_idx)
    specificity=0.5;
else
    specificity=mean(Output(neg_idx,:)<0);
end
acc = 0.5*(sensitivity+specificity);

pos=length(pos_idx);
neg=length(neg_idx);
sigma=(1/2)*sqrt( sensitivity.*(1-sensitivity)/pos + specificity.*(1-specificity)/neg );

warning on