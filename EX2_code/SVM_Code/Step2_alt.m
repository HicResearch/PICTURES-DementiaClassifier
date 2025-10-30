#############################################
# File:   Step2_alt.m
#
# 
# Purpose:
# To prepare driver table [1 worker]
#
# Author: PS Reel

% Run locally

tic
config_experiment
outer_fold = [1 : kFolds_outer];
inner_fold = [1 : kFolds_inner];

ttest_matrix = combvec(outer_fold, inner_fold);
ttest_matrix = [1:size(ttest_matrix,2); ttest_matrix];
ttest_matrix = [ttest_matrix; generate_worker_list(total_workers_ttest,size(ttest_matrix,2))]';
writetable(array2table(ttest_matrix,"VariableNames",...
      {'index','outer_fold','inner_fold','worker'}),append(driverpath,'ttest_driver.csv'));
training_matrix = combvec(outer_fold, inner_fold,p_Thres_range,C_value_range);
training_matrix = [1:size(training_matrix,2); training_matrix];
training_matrix = [training_matrix; generate_worker_list(total_workers_innertraining,size(training_matrix,2))]';

training_matrix = array2table(training_matrix,"VariableNames",{'index','outer_fold','inner_fold','p_Thres','C_value','worker'});


for d = 1:total_workers_innertraining
    training_matrix_tmp = training_matrix(training_matrix.worker == d,:);
    writetable(training_matrix_tmp,append(driverpath,num2str(d),'_training_driver.csv'));
end

end_time = toc/3600;
append('Step2 completed in ', num2str(end_time),' hours' )
fileID = fopen(append(runtimelogpath,'Step2_','runtime','_',num2str(round(end_time,5)),'_','.txt'),'w');
fprintf(fileID,append(num2str(round(end_time,5))));
fclose(fileID);

exit

function [worker_list] = generate_worker_list(total_workers, task_len)
    workers = 1: total_workers;
    worker_list = [repmat(workers, 1, floor(task_len / numel(workers))) workers(1:mod(task_len, numel(workers)))];
end

