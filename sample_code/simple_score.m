function simple_score(resudir, truthdir, scoredir)
%simple_score(resudir, truthdir, scoredir)
% Function to score the results of the benchmark, without sorting them
% resudir -- where the results are (.resu, .conf, .predict files)
% truthdir -- where the truth labels are
% scoredir -- where to store the scores

% Isabelle Guyon -- September 2003 -- isabelle@clopinet.com
% Adapted for KDD cup 2009 -- February 2009

% DISCLAIMER: ALL INFORMATION, SOFTWARE, DOCUMENTATION, AND DATA ARE PROVIDED "AS-IS" 
% THE ORGANIZERS DISCLAIMS ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. 
% IN NO EVENT SHALL ISABELLE GUYON AND/OR OTHER BENCHMARK ORGANIZERS BE LIABLE FOR ANY SPECIAL, 
% INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER ARISING OUT OF OR IN CONNECTION 
% WITH THE USE OR PERFORMANCE OF BENCHMARK SOFTWARE, DOCUMENTS, MATERIALS, PUBLICATIONS, OR 
% INFORMATION MADE AVAILABLE. 

fout=fopen([scoredir '/Simple-' date '.score'],'w') ;


% Identify the method, dataset, and result types:
[methodir, dataset, target, method] = identify(resudir, 0);

resuset={'train', 'valid', 'test'}; 


Nd=length(dataset);
Nm=length(methodir);

fprintf('Found %d datasets and %d methods\n', Nd, Nm);
aidx=strmatch('appetency', target);
cidx=strmatch('churn', target);
uidx=strmatch('upselling', target);
tidx=strmatch('toy', target);
target=target([aidx cidx uidx tidx]);
if isempty(tidx), 
    target_num=length(target); 
else
    target_num=length(target)-1; 
end

% Validation subset
for i=1:length(dataset)
    sel_idx{i}=find(load_numeric([truthdir '/' upper(dataset{i}) '/' dataset{i} '_test_subset.sel'])==1);
end

label_write([truthdir '/' upper(dataset{1}) '/' dataset{1} '_test_subset.idx'], sel_idx{1});
label_write([truthdir '/' upper(dataset{2}) '/' dataset{2} '_test_subset.idx'], sel_idx{2});

% Loop over datasets and methods:
for i=1:Nd
    fprintf(fout, '\n** %s **\n', upper(dataset{i}));
    for ll=1:length(target)
        fprintf(fout, '\t|\t%s\t', upper(target{ll}));
    end
    fprintf(fout, '\nMethod');
    for ll=1:length(target)
        fprintf(fout, '\tTrain\tValid\tTest');
    end
    fprintf(fout, '\tSCORE\n');

    for j=1:length(methodir)
        aucval=-1*ones(length(resuset),1);
        aucbar=-1*ones(length(resuset),1);
        kk=1;
        mu=0;
        va=0;
        tn=0;
        for ll=1:length(target)
            for k=1:length(resuset)
                % Get the truth values (note: the 'feat' also have truth values)
                if strcmp(resuset{k}, 'valid')
                    Y=load_numeric([truthdir '/' upper(dataset{i}) '/' dataset{i} '_test_' target{ll} '.labels']);
                    Y=Y(sel_idx{i});
                else
                    Y=load_numeric([truthdir '/' upper(dataset{i}) '/' dataset{i} '_' resuset{k} '_' target{ll} '.labels']);
                end
                % Get the results
                if strcmp(resuset{k}, 'valid')
                    Y_resu=fload([resudir '/' methodir{j} '/' dataset{i} '_test_' target{ll} '.resu']);
                    if ~isempty(Y_resu), Y_resu=Y_resu(sel_idx{i}); end
                    %label_write([resudir '/' methodir{j} '/' dataset{i} '_valid_' target{ll} '.resu'], Y_resu);
                else
                    Y_resu=fload([resudir '/' methodir{j} '/' dataset{i} '_' resuset{k} '_' target{ll} '.resu']);
                end
                if ~isempty(Y_resu) & ~isempty(Y)
                    [aucval(kk), aucbar(kk)]=auc(Y_resu, Y);
                    if ~strcmp(target{ll}, 'toy') & strcmp(resuset{k}, 'test')
                        mu=mu+aucval(kk);
                        va=va+aucbar(kk)^2;
                        tn=tn+1;
                    end
                end
                kk=kk+1;
            end % for k
        end % for ll
        fprintf(fout, '%s', method{j});
        for kk=1:length(aucval)            
            fprintf(fout, '\t%5.4f+-%5.4f',  aucval(kk), aucbar(kk));
        end
        if tn>1, 
            mu=mu/tn;
            va=va/tn;
            fprintf(fout, '\t%5.4f+-%5.4f\n',  mu, sqrt(va));
        else
            fprintf(fout, '\t%5.4f+-%5.4f\n',  -1, -1);
        end
    end % for j
end % for i

fclose(fout);

        
    
