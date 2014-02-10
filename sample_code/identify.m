function [methodir, dataset, target, method] = identify(dirname, test_only, Flist)
% [methodir, dataset, target, method] = identify(dirname, test_only, Flist)
% Identify the methods and datasets 
% If test_only file is on, refuse dir without test results.

%%% AMIR BEGINS %%% Replaced '\' with filresep, '\' is for windows only and causes problems in Linux

ext='.resu';

methodlist=dir(dirname);
ll=length(methodlist)-2;
methodir=cell(ll,1);
method=cell(ll,1);

for i=1:ll
    methodir{i}=methodlist(i+2).name;
end
if nargin>2 
    methodir=intersect(methodir,Flist);
    ll=length(methodir);
end
% Code to fetch method name from the result directory (not used here)
for i=1:ll
    mid=[];%label_read([dirname filesep methodir{i} '\method']);
    gid=[];%label_read([dirname filesep methodir{i} '\name']);
    if ~isempty(gid) & ~isempty(mid), 
        m1=mid{1};
        m1(m1==' ')='_';
        m2=gid{1};
        m2(m2==' ')='_';
        method{i}=[methodir{i} ' ' m1 ' ' m2]; 
    else
        method{i}=methodir{i};
    end
end
% Restrict to test results
if test_only
    idx_good=[];
	for i=1:ll
        istest=dir([dirname filesep methodir{i} filesep '*_test*' ext]);
        if length(istest)>=1, idx_good=[idx_good, i]; end
	end
	methodir=methodir(idx_good); 
    method=method(idx_good); 
    ll=length(methodir);
end
% List the datasets
dataset={};
for i=1:ll
    resulist=dir([dirname filesep methodir{i} filesep '*' ext]);
    pp=length(resulist);
    ds=cell(pp,1); dp=cell(pp,1);
    for j=1:pp
        name=resulist(j).name;
        s=findstr('_train', name);
        if ~isempty(s), 
            ds{j}=name(1:s(1)-1); 
        else
            ds{j}='';
        end
    end
    for j=1:pp
        name=resulist(j).name;
        s=findstr('_test', name);
        if ~isempty(s), 
            dp{j}=name(1:s(1)-1); 
        else
            dp{j}='';
        end
    end
    dataset=[dataset; ds; dp];
end
dataset=unique(dataset);
dataset=setdiff(dataset, {''});

% List the target types
target={};
for i=1:ll
    resulist=dir([dirname filesep methodir{i} filesep '*' ext]);
    pp=length(resulist);
    ds=cell(pp,1); dp=cell(pp,1);
    for j=1:pp
        name=resulist(j).name;
        s=findstr('_', name);
        d=findstr('.', name);
        if ~isempty(s), 
            ds{j}=name(s(length(s))+1:d-1); 
        else
            ds{j}='';
        end
    end
    for j=1:pp
        name=resulist(j).name;
        s=findstr('_', name);
        d=findstr('.', name);
        if ~isempty(s), 
            dp{j}=name(s(length(s))+1:d-1); 
        else
            dp{j}='';
        end
    end
    target=[target; ds; dp];
end
target=unique(target);
target=setdiff(target, {''});

%%% AMIR ENDS %%%

return
