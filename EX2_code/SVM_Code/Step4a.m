#############################################
# File:   Step4a.m
#
# 
# Purpose:
# Validate inner training testing completion and aggregate all files and prepare one file for each outer fold
#
# Author: PS Reel


% Run locally

tic
config_experiment
M =[];

append('Number of workers  = ',num2str(total_workers_innertraining));

for d = 1:total_workers_innertraining
    M = [M;readtable(strcat(innertraintestpath,num2str(d),'_innertraintest.csv'),'PreserveVariableNames',true)];
end

N =[];
for d = 1:total_workers_innertraining
    N = [N;readtable(strcat(driverpath,num2str(d),'_training_driver.csv'),'PreserveVariableNames',true)];
end

if size(M,1) == size(N,1)
        'inner loop training completion validated'
        fileID = fopen(append(exppath,'/','Inner_loop_validated.txt'),'w');
        fprintf(fileID,append('Inner_loop_validated'));
        fclose(fileID);
else
    'Inner loop training incomplete. Check Step 4!'
    fileID = fopen(append(exppath,'/','ERROR_Inner_loop_incomplete.txt'),'w');
    fprintf(fileID,append('ERROR_Inner_loop_incomplete'));
    fclose(fileID);
end


for j = 1:kFolds
    inner_results_tmp = M(M.outer_fold == j,:);
    writetable(inner_results_tmp,append(innertraintestpath,'innertraintest_results_outerfold_',num2str(j),'.csv'));
end

end_time = toc/3600;
append('Step4a completed in ', num2str(end_time),' hours' )
fileID = fopen(append(runtimelogpath,'Step4a_','runtime','_',num2str(round(end_time,5)),'_','.txt'),'w');
fprintf(fileID,append(num2str(round(end_time,5))));
fclose(fileID);
exit

 

