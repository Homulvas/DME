% Some examples of CLOP models

% Linear ridge regression (with subsampling to go faster and balance the
% dataset)

KRIDGE = chain({subsample({'p_max=20000', 'balance=1'}), kridge});