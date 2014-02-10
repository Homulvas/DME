function A=load_text(f, pat_num, feat_num, feat_type)
%A=load_text(f, pat_num, feat_num, feat_type)
% Load a text file in the Orange format.
% If pat_num is given, read only the first pat_num entries.
% If feat_num is given, checks that the number of features is correct.
% feat_type: 0 ==> read all features as strings.
%            -1 => read only the numeric features (as numbers).
%            1 => read only the categorical variables (as strings).

% Isabelle Guyon -- Feb. 2009

if nargin<2, pat_num=[]; end
if nargin<3, feat_num=[]; end
if nargin<4, feat_type=0; end

fp=fopen(f, 'r');

% Get the number of features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num=length(parse_line(fgetl(fp)));
if num==230
    numeric_num=190;
else
    numeric_num=14740;
end
categorical_num=num-numeric_num;
    
if feat_type==-1
    max_num=numeric_num;
elseif feat_type==1
    max_num=categorical_num;
    feat_type=numeric_num;
else
    max_num=num;
end

if isempty(feat_num)
    feat_num=max_num;
else
    if feat_num>max_num | feat_num <=0
        error('Wrong number of features\n');
    end
end
fprintf('Reading %d features\n', feat_num);

% Dimension the data matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(pat_num)
    fprintf('Reading %d patterns\n', pat_num);
    fprintf('Percent done: ');
    percent_done=0;
    old_percent_done=0;
    monitor=1;
    if feat_type == -1
        A=zeros(pat_num, feat_num);
    else
        A=cell(pat_num, feat_num);
    end
else
    if feat_type == -1
        A=[];
    else
        A={};
    end
    pat_num=Inf;
    monitor=0;
end
    
% Read the data
%%%%%%%%%%%%%%%
for k=1:pat_num
    tline = fgetl(fp);
    if ~ischar(tline), break, end
    A(k,:)=parse_line(tline, feat_num, feat_type);
    if monitor
        percent_done=floor(k/pat_num*100);
        if ~mod(percent_done,10) & percent_done~=old_percent_done,
            fprintf('%d%% ', percent_done);
        end
        old_percent_done=percent_done;
    end
end

fprintf('\n');

fclose(fp);
