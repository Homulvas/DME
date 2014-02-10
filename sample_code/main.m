% -o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-
%                       SAMPLE CODE FOR THE KDD CUP 2009 
%                       FAST SCORING ON A LARGE DATABASE
%             Isabelle Guyon -- isabelle@clopinet.com -- March 2009
% -o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-

% DISCLAIMER: ALL INFORMATION, SOFTWARE, DOCUMENTATION, AND DATA ARE PROVIDED "AS-IS" 
% ISABELLE GUYON AND/OR OTHER ORGANIZERS DISCLAIM ANY EXPRESSED OR IMPLIED WARRANTIES, 
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
% FOR ANY PARTICULAR PURPOSE, AND THE WARRANTY OF NON-INFRIGEMENT OF ANY THIRD PARTY'S 
% INTELLECTUAL PROPERTY RIGHTS. IN NO EVENT SHALL ISABELLE GUYON AND/OR OTHER ORGANIZERS 
% BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
% ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF SOFTWARE, DOCUMENTS, 
% MATERIALS, PUBLICATIONS, OR INFORMATION MADE AVAILABLE FOR THE CHALLENGE.

%% Initialization
clear all
close all
%clc

%% -o-|-o-|-o-|-o-|-o-|-o-|-o- BEGIN USER-PREFERENCES -o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-

% 1) User-defined directories (no slash at the end of the names):
% --------------------------------------------------------------
% The present set up supposes that you are now in the directory sample_code
% and you have the following directory tree, where <my_root> is you project directory:
% <my_root>/Data (data matrices)
% <my_root>/Labels (truth values or labels)
% <my_root>/Results (resu files; one subdirectory per model tried)
% <my_root>/Score (peformance of the models)
% <my_root>/Zipped (zip files of the results, ready to go)

my_root     = '../';  % Change that to the directory of your project

code_dir    = [my_root '/sample_code'];
data_dir    = [my_root '/Data'];    %  Contains two subdirectories: orange_large and orange_small
truth_dir   = [my_root '/Labels'];  %  Contains two subdirectories: orange_large and orange_small
resu_dir    = [my_root '/Results']; % Where the results will end up.    
score_dir   = [my_root '/Score'];   % Computed performances.    
zip_dir     = [my_root '/Zipped'];  % Zipped files with results ready to go!

% If you just downloaded the sample code, you do not have the spider
% and Challenge Learning Object Package (CLOP). 
% You may download them it from: http://clopinet.com/CLOP/. 
% But you do not need to, you can just run the simple 'lambda' example,
% which does not used CLOP.

DoNotUseClop    = 1;                % Set to 1 if you do not want to use CLOP
clop_root='Z:\user On My Mac\Isabelle\Projects\Challenges\ChallengeBook';
code_dir    = [clop_root '/CLOP'];  % Path to CLOP or '' if you do not use CLOP.

DoNotLoadTestData   = 0;            % To save memory, does not load the test data
                                    % at training time.

FoldNum = 0;                        % If this flag is positive, 
                                    % k-fold cross-validation is performed.
                                    % with k=FoldNum.
ShowStats = 0;                      % Set to 1 to see data statistics.

% 2) Choose your data, tasks and models
% -------------------------------------
dataset     = {'orange_small'};     % 'orange_large' not supported so far
taskset     = {'churn', 'appetency', 'upselling', 'toy'}; %'churn'};%, 
if DoNotUseClop
    modelset    = {'lambda'};       % Use the 'lambda' model
                                    % if you do not use CLOP.
else
    modelset    = {'naive', 'kridge', 'rf'}; 
                                    % This should be an array of model names
                                    % from the CLOP package.
end
% Advanced CLOP users may write a script that creates models 
% with hyper-parameters or compound models using chain and ensemble:
%clop_examples; % This is an example of such a script.

%% -o-|-o-|-o-|-o-|-o-|-o-|-o- END USER-PREFERENCES -o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-

% Set the path and defaults properly; create directories
% ------------------------------------------------------
clop_is_used=0;
if exist(code_dir, 'dir')==7, 
    addpath(code_dir);
else
    fprintf('No CLOP directory found, using only lambda model\n');
    modelset    = {'lambda'};   
end
if exist('use_spider_clop.m') == 2 & ~DoNotUseClop
    use_spider_clop(code_dir);
    clop_is_used=1;
elseif exist('sample_code_version.m') == 2, 
    fprintf('Sample code version : %s\n', code_version('sample_code'));
else disp 'ERROR: Wrong code path. Check your directories and path variables.';
    if exist('README.txt') == 2, type README.txt; end
    if exist('Data/README.txt') == 2, type Data/README.txt; end
    if exist('Clop/README.txt') == 2, type Clop/README.txt; end
    return; 
end
if isempty(modelset), modelset =  {'lambda'};  end
makedir(resu_dir);
makedir(zip_dir);
makedir(score_dir);

%% Train/Test
% LOOP OVER DATASETS 
% ===================
for k = 1:length(dataset)
    
	data_name   = dataset{k};
    
    fprintf('\n-o-|-o-|-o-|-o-|-o-|-o-      %s      -o-|-o-|-o-|-o-|-o-|-o-\n', upper(data_name));
    fprintf('\n-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-\n\n');

    % Create a data structure and check the data
    %===========================================
    fprintf('-- %s loading data --\n', upper(data_name));
    input_dir   = [data_dir '/' upper(data_name)];
    input_name  = [input_dir '/' data_name];

    % List of categorical variables
    if strfind(data_name, 'large')
        categorical_list=[14740:15000];
        fprintf('Only small dataset supported so far\n');
        return
    else
        categorical_list=[191:230];
    end

    % Loading data and labels 
    % (categorical variables are turned to numeric categories)
    fprintf('-- Training data\n');
    Train=load_orange(data_dir, 1, 1);
      
    if DoNotLoadTestData
        Test=[]; Dte=[];
    else
        fprintf('-- Test data\n');
        Test=load_orange(data_dir, 0, 1);
    end
    
    % Preprocessing 
    fprintf('-- %s preprocessing data --\n', upper(data_name));
    if clop_is_used
        % Fill in missing values, remove constant variables, and
        % standardize variables
        my_prepro=chain({missing, rmconst, standardize});
        [Dtr, my_prepro]=train(my_prepro, data(Train.X));
        if ~isempty(Test)
            Dte=test(my_prepro, data(Test.X));
        end
    else
        [Dtr.X, param]=lambda_prepro(Train.X);
        if ~isempty(Test)
            Dte.X=lambda_prepro(Test.X, param);
        end
    end
            
    % LOOP OVER TASKS 
    % ================
    for i = 1:length(taskset)
        
        task_name  = taskset{i};
        
        fprintf('\n-o-|-o-|-o-|-o-|-o-|-o- %s %s -o-|-o-|-o-|-o-|-o-|-o-\n', upper(data_name), upper(task_name));
        fprintf('\n-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-\n\n');
        
        if isempty(Train.(task_name))
            fprintf('No training labels available for task %s\n', task_name{i});
            continue
        end    
        
        Dtr.Y=Train.(task_name);
        Dte.Y=Test.(task_name);
        
        if clop_is_used & ShowStats
            data_stat(data(Train.X, Train.(task_name)), data(Test.X, Test.(task_name)), categorical_list);
        end
        
        % LOOP OVER MODELS 
        % ================
        for j = 1:length(modelset)

            model_name  = modelset{j};     

            resu_name   = [resu_dir '/' model_name ];
            makedir(resu_name);
            resu_name   = [resu_name '/' data_name];        
            
            fprintf('-- %s_%s training model %s\n', upper(data_name), upper(task_name), upper(model_name));         
            tic;
            if clop_is_used
                % Subsample data to facilitate training
                my_model=chain({subsample({'p_max=20000', 'balance=1'}), eval(model_name)});
                [tr_output, trained_model]=train(my_model, Dtr);
                tr_output=test(trained_model, Dtr); % We need to recompute the training error because of the subsampling
                [tr_auc, tr_bar]=auc(tr_output); % tr_output is a data structure
                tr_output=tr_output.X; % the X member are the predictions and the Y member the targets
            else
                %idx=lambda_feat_select(Dtr.X, Dtr.Y, 211); % Use the top ranking features
                idx=1:size(Dtr.X, 2);
                param=lambda_train(Dtr.X, Dtr.Y, idx);
                tr_output=lambda_predict(Dtr.X, param, idx);
                [tr_auc, tr_bar]=auc(tr_output, Dtr.Y);
            end
            fprintf('-- %s_%s model %s trained in %5.2f seconds\n', upper(data_name), upper(task_name), upper(model_name), toc);  
            
            fprintf('-- %s_%s testing model %s\n', upper(data_name), upper(task_name), upper(model_name));
            te_output=[]; te_auc=[]; 
            tic;
            if ~isempty(Dte)
                if clop_is_used
                    te_output=test(trained_model, Dte);
                    if ~isempty(Dte.Y), [te_auc, te_bar]=auc(te_output); end
                    te_output=te_output.X;
                else
                    te_output=lambda_predict(Dte.X, param, idx);
                    if ~isempty(Dte.Y), [te_auc, te_bar]=auc(te_output, Dte.Y); end
                end
            end
            fprintf('-- %s_%s model %s tested in %5.2f seconds\n', upper(data_name), upper(task_name), upper(model_name), toc);  
           
            fprintf('Training AUC=%5.4f+-%5.4f\n', tr_auc, tr_bar);
            if ~isempty(te_auc)
                fprintf('Test AUC=%5.4f+-%5.4f\n', te_auc, te_bar);
            end
            
            % Save the results
            %=================
            fprintf('-- %s_%s saving the results of model %s\n', upper(data_name), upper(task_name), upper(model_name));
            save_outputs([resu_name '_train_' task_name '.resu'], tr_output);        
            if ~isempty(te_output)
                save_outputs([resu_name '_test_' task_name '.resu'], te_output);        
            end           
            fprintf('-- %s_%s results of %s saved as %s_*_%s.resu\n', upper(data_name), upper(task_name), upper(model_name), resu_name, task_name);

            fprintf('\n-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-\n');
            
        end % for j loop on models
    end % for i loop on tasks
end % for k loop on datasets
    
        
%% Zip the archives so they are ready to go!
%%-----------------------------------------
if ~usejava('jvm'), warning('Java is not loaded, failed to generate ZIP files !!!'); return; end
for k = 1:length(modelset)
    model_name  = modelset{k};
    zip_name    = zipall(model_name, resu_dir, zip_dir);
    if ~isempty(zip_name)
        fprintf('-- %s zip archive created, see %s --\n', upper(model_name), zip_name);
    end
end

% Score the models
fprintf('-- scoring the models --\n');
%simple_score(resu_dir, truth_dir, score_dir);


