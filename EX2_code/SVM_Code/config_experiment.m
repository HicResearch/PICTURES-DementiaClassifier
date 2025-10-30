#############################################
# File:   config_experiment.m
#
# 
# Purpose:
# To configure the various steps of the experiment
#
# Author: PS Reel

format longG
Rseed = 1;
seed = Rseed;
exppath = strcat('C:\Local_Work\results\',num2str(seed));
if not(isfolder(exppath))
    mkdir(exppath)
end

%Step1
%addpath('/zfs/test_EX2');
imagespath = 'C:\Local_Work\Data\IXI\IXI-T1\';
driverpath = strcat('C:\Local_Work\results\',num2str(seed),'\driver\');
splitpath = strcat('C:\Local_Work\results\',num2str(seed),'/splits/');
runtimelogpath = strcat('C:\Local_Work\results\',num2str(seed),'/runtime_log/');
cohortlistpath = 'C:\Local_Work\Data\IXI';
data_file = 'IXI_table_40.xlsx'; %25_test %_48 130 518
kFolds = 4; kFolds_outer = 4; kFolds_inner = 4;

Step0


%Step2
total_workers_ttest = 16; total_workers_innertraining = 16;
num_var_p_values = 8; num_var_SVM = 8;
p_Thres_range = round(linspace(min_p,max_p,num_var_p_values),10); % 10 is the round of digit here 
C_value_range = round(linspace(min_C,max_C,num_var_SVM),0)
K_value = 'nan';

%Step3
conditions = {'Below_48.5_years','Above_48.5_years'};
projectpath = 'C:\Local_Work\EX2_code\SVM_Code\';
ttestoutpath = strcat('C:\Local_Work\results\',num2str(seed),'/ttest');
spmpath = 'C:\Local_Work\EX2_code\spm12\spm12\';

%Step3a
%NA

%Step4
P = 8; % parpool workers max = 8
%profilerpath = '/zfs/test_EX2/job-out/profiler/';

%Step4a
%NA

%Step5
innertraintestpath = strcat('C:\Local_Work\results\',num2str(seed),'\inner_train_test\');
outertraintestpath = strcat('C:\Local_Work\results\',num2str(seed),'\outer_train_test\');




