function v=parse_line(tline, num, feat_type)
% v=parse_line(tline, num, feat_type)

% Isabelle Guyon -- Feb. 2009

if nargin<3, feat_type=0; end
if nargin<2 
    num=[];
end

tabs=strfind(tline, sprintf('\t'));
tabs=[0 , tabs, length(tline)+1];
if isempty(num),
    num=length(tabs)-1;
end
if feat_type==-1 % numeric
    v=zeros(1,num);
    for k=1:num
        tt=tline(tabs(k)+1:tabs(k+1)-1);
        if isempty(tt)
            v(k)=NaN;
        else
            v(k)=str2num(tt);
        end
    end
else
    v=cell(1,num);
    for k=1:num
        v{k}=tline(tabs(feat_type+k)+1:tabs(feat_type+k+1)-1);
    end
end
