#############################################
# File:   Step1.m
#
# 
# Purpose:
# To prepare outer/inner splits [1 worker]
#
# Author: PS Reel

% Run locally

% Step 2: 
% Step 3: generate t-test results using SPM [n workers]
% Step 4: run training [n workers]

tic
config_experiment
EX2 = readmatrix(strcat(cohortlistpath,'/',data_file), OutputType="char")'; 

allData = EX2(1,:);
targets = EX2(2,:)';

append('Seed number = ', num2str(seed)) 

allData = allData';

rng(seed);
partitions_outer = cvpartition(targets,'Kfold', kFolds_outer); %, 'Stratify', true);

%create folder for saving drivers
if not(isfolder(driverpath))
    mkdir(driverpath)
end

if not(isfolder(splitpath))
    mkdir(splitpath)
end

if not(isfolder(runtimelogpath))
    mkdir(runtimelogpath)
end

disp('K-Fold Splitting...');
disp('');

for outer_n = 1 : kFolds_outer %length(allData)
    
    kIdx_outer = training(partitions_outer,outer_n); % partition n-1 

    trainData_outer = allData(kIdx_outer); 
    trainTarg_outer = targets(kIdx_outer);
    
    kIdxtest_outer = partitions_outer.test(outer_n);
    
    testData_outer = allData(kIdxtest_outer); 
    testTarg_outer = targets(kIdxtest_outer);
    
    % prepare the inner loop folds
    rng(seed);
    partitions_inner = cvpartition(trainTarg_outer,'Kfold', kFolds_inner);
    for inner_n = 1 : kFolds_inner
        kIdx_inner = training(partitions_inner,inner_n); % partition n-1 
        
        trainData_inner = trainData_outer(kIdx_inner); 
        trainTarg_inner = trainTarg_outer(kIdx_inner);
    

        kIdxtest_inner = partitions_inner.test(inner_n);
    
        testData_inner = trainData_outer(kIdxtest_inner); 
        testTarg_inner = trainTarg_outer(kIdxtest_inner);
        
        unique_vals = unique(testTarg_inner);
        sum(ismember(trainTarg_inner,unique_vals{1}))
        sum(ismember(trainTarg_inner,unique_vals{2}))
        append(' ')


        %save inner loop flags for training (1) and test (0)
        if inner_n == 1
            inner_split_info = [EX2(:,kIdx_outer)' num2cell(kIdx_inner)];
        else
            inner_split_info = [inner_split_info num2cell(kIdx_inner)];
        end
    end


variable_names = {'V','filenames','class'};
fold_names = cellstr(genvarname(repmat("fold_",1,kFolds_inner),"fold_"));
variable_names_new = [variable_names,fold_names];

writetable(cell2table(inner_split_info,"VariableNames",variable_names_new ),append(splitpath,num2str(outer_n),'_outersplitdetails.csv'));


    %save the outer loop flags for training (1) and test (0) set
    if outer_n == 1
        outer_split_info = [EX2;num2cell(kIdx_outer)']';
    else
        outer_split_info = [outer_split_info';num2cell(kIdx_outer)']';
    end
end

variable_names = {'V','filenames','class'};
fold_names = cellstr(genvarname(repmat("fold_",1,kFolds_outer),"fold_"));
variable_names_new = [variable_names,fold_names];

writetable(cell2table(outer_split_info,"VariableNames",variable_names_new),append(splitpath,'outersplitinfo.csv'));


end_time = toc/3600;
append('Step1 completed in ', num2str(end_time),' hours' )
fileID = fopen(append(runtimelogpath,'Step1_','runtime','_',num2str(round(end_time,5)),'_','.txt'),'w');
fprintf(fileID,append(num2str( ...
    round(end_time,5))));
fclose(fileID);

exit
