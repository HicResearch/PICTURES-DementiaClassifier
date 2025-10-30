#############################################
# File:   Step5.m
#
# 
# Purpose:
# Extract the best parameters form inner loops [run on n=kFold workers]
#
# Author: PS Reel


tic
config_experiment

ttest_driver = readtable(strcat(driverpath,'ttest_driver.csv'));

for i = 1:kFolds

worker_id = i;

tmp =readtable(append(innertraintestpath,'innertraintest_results_outerfold_',num2str(worker_id),'.csv'));


tmp.HP_String = cellstr(strcat(num2str(tmp.p_Thres,'%.10f'),',',num2str(tmp.C_value),',',num2str(tmp.K_value)));
tmp.HP_String = categorical(tmp.HP_String);
vars = ["ACC"];
tmp_meanACC = groupsummary(tmp,"HP_String","mean",vars); % meanACCaccrossinnerfolds
[tmp_bestACC,idx] = max(tmp_meanACC.mean_ACC);
tmp_bestHP = string(tmp_meanACC.HP_String(idx));
bestHP_results = tmp(tmp.HP_String == tmp_bestHP,:);

save(strcat(innertraintestpath,num2str(worker_id),'_bestHP.mat'),"tmp_bestACC","tmp_bestHP","bestHP_results");
writetable(bestHP_results,strcat(innertraintestpath,num2str(worker_id),'_bestHP.csv'));
writetable(tmp,strcat(innertraintestpath,num2str(worker_id),'_innersummaryresults.csv'));

end_time = toc/3600;
append('Step5 Best parameters found for outer fold ', num2str(worker_id), ' in ', num2str(end_time),' hours' )
fileID = fopen(append(runtimelogpath,'Step5_',num2str(worker_id),'_','runtime','_',num2str(round(end_time,5)),'_','.txt'),'w');
fprintf(fileID,append(num2str(round(end_time,5))));
fclose(fileID);
end
exit

