#############################################
# File:   Step4_alt.m
#
# 
# Purpose:
# Generate inner training results [run on n workers]
#
# Author: PS Reel


tic
config_experiment

ttest_driver = readtable(strcat(driverpath,'ttest_driver.csv'));

for i = 1:total_workers_innertraining

worker_id = i;

tmp_training_driver = readtable(strcat(driverpath,num2str(worker_id),'_training_driver.csv')); % better split this file to make it faster



if not(isfolder(innertraintestpath))
    mkdir(innertraintestpath)
end

T = array2table(nan(0,21),'VariableNames',{ 'outer_fold','inner_fold','worker_id','p_Thres', 'n_voxels','C_value', 'K_value','AUC','ACC', 'SENS','SPEC','PPV','NPV','NUM_OBS', 'NUM_CC','NUM_IC','CM11','CM12','CM21','CM22','HP_String'});
writetable(T,strcat(innertraintestpath,num2str(worker_id),'_innertraintest.csv'),'WriteVariableNames',true );

for i = 1:size(tmp_training_driver,1)
    tmp_outer = tmp_training_driver.outer_fold(i);
    tmp_inner  = tmp_training_driver.inner_fold(i);
    tmp_p_Thres = tmp_training_driver.p_Thres(i); 
    tmp_C_value = tmp_training_driver.C_value(i);
    tmp_K_value = K_value;
    
    mask_folder = strcat(num2str(tmp_outer),'_',num2str(tmp_inner));%,'_',num2str(tmp_p_Thres));

    if (isfile(strcat(ttestoutpath,'/',mask_folder,'/',num2str(tmp_p_Thres,'%.10f'),'_traindata.mat')) && isfile(strcat(ttestoutpath,'/',mask_folder,'/',num2str(tmp_p_Thres,'%.10f'),'_testdata.mat')))
        
        TR = load(strcat(ttestoutpath,'/',mask_folder,'/',num2str(tmp_p_Thres,'%.10f'),'_traindata.mat')); %train_Vols train_Vol_Labels
        TE = load(strcat(ttestoutpath,'/',mask_folder,'/',num2str(tmp_p_Thres,'%.10f'),'_testdata.mat')); %test_Vols test_Vol_Labels
        if (size(TR.train_Vols,2) | size(TE.test_Vols,2)) ~= 0
            anSVMModel = fitcsvm(TR.train_Vols, TR.train_Vol_Labels, ...
                'KernelFunction', 'gaussian', 'KernelScale', 'auto', 'BoxConstraint', tmp_C_value);
            [pred_label, score] = predict(anSVMModel, TE.test_Vols); %, testTarg);
            [~,~, ~, AUC] = perfcurve(TE.test_Vol_Labels,abs(score(:,2)),'Above_48.5_years');
            perf = classperf(TE.test_Vol_Labels,pred_label);
            best_K = anSVMModel.KernelParameters.Scale;
            Num_correctly_classified = perf.DiagnosticTable(1,1) + perf.DiagnosticTable(2,2);
            Num_incorrectly_classified = perf.DiagnosticTable(1,2) + perf.DiagnosticTable(2,1);
            T = table([tmp_outer, tmp_inner, worker_id,tmp_p_Thres, size(TR.train_Vols,2),tmp_C_value, best_K,AUC, perf.CorrectRate, perf.Sensitivity, perf.Specificity, perf.PositivePredictiveValue,perf.NegativePredictiveValue,perf.NumberOfObservations,Num_correctly_classified,Num_incorrectly_classified,perf.DiagnosticTable(1,1),perf.DiagnosticTable(1,2),perf.DiagnosticTable(2,1),perf.DiagnosticTable(2,2),cellstr(strcat(num2str(tmp_p_Thres,'%.10f'),',',num2str(tmp_C_value),',',num2str(tmp_K_value)))]); 
            writetable(T,strcat(innertraintestpath,num2str(worker_id),'_innertraintest.csv'),WriteMode='append');
        else
            T = table([tmp_outer, tmp_inner, worker_id,tmp_p_Thres, size(TR.train_Vols,2),tmp_C_value, tmp_K_value,NaN, NaN, NaN, NaN, NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,cellstr(strcat(num2str(tmp_p_Thres,'%.10f'),',',num2str(tmp_C_value),',',num2str(tmp_K_value)))]); 
            writetable(T,strcat(innertraintestpath,num2str(worker_id),'_innertraintest.csv'),WriteMode='append');
        end
    else
        append('p_val = ', num2str(tmp_p_Thres))
        append('looking for ', strcat(ttestoutpath,'/',mask_folder,'/',num2str(tmp_p_Thres,'%.10f'),'_traindata.mat'))
        'Warning! Run ttest first for feature selection'
    end

end

end_time = toc/3600;
append('Step4 inner train test processing complete for node ', num2str(worker_id), ' in ', num2str(end_time),' hours' )
fileID = fopen(append(runtimelogpath,'Step4_',num2str(worker_id),'_','runtime','_',num2str(round(end_time,5)),'_','.txt'),'w');
fprintf(fileID,append(num2str(round(end_time,5))));
fclose(fileID);


end
exit
