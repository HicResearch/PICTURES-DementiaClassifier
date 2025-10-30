#############################################
# File:   Step7_alt.m
#
# 
# Purpose:
# Validate outer fold training testing completion and aggregate all files and prepare one file for each outer fold.
#
# Author: PS Reel

tic
config_experiment

M =[];
for d = 1:kFolds
    M = [M;readtable(strcat(outertraintestpath,num2str(d),'_outertraintest.csv'),'PreserveVariableNames',true)];
end

M.min_p = repmat(min_p,size(M,1),1); M.max_p = repmat(max_p,size(M,1),1);
M.min_C = repmat(min_C,size(M,1),1); M.max_C = repmat(max_C,size(M,1),1);

writetable(M,strcat(exppath,'/Final_summary.csv'),'WriteVariableNames',true );

'Outer fold results summarised sucessfully'

end_time = toc/3600;
append('Step7 completed in ', num2str(end_time),' hours' )
fileID = fopen(append(runtimelogpath,'Step7_','runtime','_',num2str(round(end_time,5)),'_','.txt'),'w');
fprintf(fileID,append(num2str(round(end_time,5))));
fclose(fileID);


% calculate total time
%files_data = dir(runtimelogpath);
%files = string({files_data.name});

%t1 = table2array(readtable(strcat(runtimelogpath,'/',files(strmatch("Step1_",files)))));
%t2 = table2array(readtable(strcat(runtimelogpath,'/',files(strmatch("Step2_",files)))));
%t3 = table2array(readtable(strcat(runtimelogpath,'/',files(strmatch("Step3_1_",files)))));
%t3a = table2array(readtable(strcat(runtimelogpath,'/',files(strmatch("Step3a_",files)))));
%t4 = table2array(readtable(strcat(runtimelogpath,'/',files(strmatch("Step4_1_",files)))));
%t4a = table2array(readtable(strcat(runtimelogpath,'/',files(strmatch("Step4a_",files)))));
%t5= table2array(readtable(strcat(runtimelogpath,'/',files(strmatch("Step5_1_",files)))));
%t6 = table2array(readtable(strcat(runtimelogpath,'/',files(strmatch("Step6_1_",files)))));
%t7 = table2array(readtable(strcat(runtimelogpath,'/',files(strmatch("Step7_",files)))));
%ttotal = t1+t2+t3+t4+t4a+t5+t6+t7;

%append('Total time for experiment was ', num2str(ttotal),' hours' )
%fileID = fopen(append(exppath,'/Total_runtime_',num2str(round(ttotal,5)),'_','.txt'),'w');
%fprintf(fileID,append(num2str(round(ttotal,5))));
%fclose(fileID);

%rmdir(ttestoutpath,"s")
%'Temp ttest folder deleted successfully'

exit
