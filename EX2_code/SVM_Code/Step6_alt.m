#############################################
# File:   Step6_alt.m
#
# 
# Purpose:
# Generate outer loop training results using best hyperparameters [run on n=kFold workers]
#
# Author: PS Reel


tic
config_experiment

ttest_driver = readtable(strcat(driverpath,'ttest_driver.csv'));

for i = 1:kFolds

worker_id = i;

addpath(spmpath);


spm('Defaults', 'PET');

if not(isfolder(outertraintestpath))
    mkdir(outertraintestpath)
end

%prepare result logger
T = array2table(nan(0,20),'VariableNames',{ 'outer_fold','worker_id','p_Thres', 'n_voxels','C_value', 'K_value','AUC','ACC', 'SENS','SPEC','PPV','NPV','NUM_OBS', 'NUM_CC','NUM_IC','CM11','CM12','CM21','CM22','HP_String'});
writetable(T,strcat(outertraintestpath,num2str(worker_id),'_outertraintest.csv'),'WriteVariableNames',true );



L = load(strcat(innertraintestpath,num2str(worker_id),'_bestHP.mat'));
tmp_data = readtable(strcat(splitpath,'outersplitinfo.csv')); % better split this file to make it faster

idx_train = use_eval(strcat('tmp_data.','fold_',num2str(worker_id),' == 1'), tmp_data);
tmp_train_label = table2cell(tmp_data(idx_train,3));
tmp_train_data = table2cell(tmp_data(idx_train,2));
idx_test = use_eval(strcat('tmp_data.','fold_',num2str(worker_id),' == 0'), tmp_data);
tmp_test_label = table2cell(tmp_data(idx_test,3));
tmp_test_data = table2cell(tmp_data(idx_test,2));

if not(isfolder(outertraintestpath))
    mkdir(outertraintestpath)
end

[max_value,ind]=max(L.bestHP_results.ACC);
best_p_Thres = L.bestHP_results.p_Thres(ind);
best_K_value = L.bestHP_results.K_value(ind);
best_C_value = L.bestHP_results.C_value(ind); 
mask_folder = strcat(string(L.bestHP_results.outer_fold(ind)),'_',string(L.bestHP_results.inner_fold(ind)));

if isfile(strcat(ttestoutpath,'/',mask_folder,'/',num2str(best_p_Thres,'%0.10f'),'_binarymask.mat'))
    append('Applying best mask to outer fold ',num2str(worker_id))
    
    mask_module(ttestoutpath,outertraintestpath,worker_id, tmp_train_data, tmp_train_label, mask_folder, best_p_Thres,'train')
    mask_module(ttestoutpath,outertraintestpath,worker_id,tmp_test_data, tmp_test_label, mask_folder, best_p_Thres ,'test')

    TR = load(strcat(outertraintestpath,'/',num2str(worker_id),'/',mask_folder,'/',num2str(best_p_Thres,'%0.10f'),'_traindata.mat')); %train_Vols train_Vol_Labels
    TE = load(strcat(outertraintestpath,'/',num2str(worker_id),'/',mask_folder,'/',num2str(best_p_Thres,'%0.10f'),'_testdata.mat')); %test_Vols test_Vol_Labels

    anSVMModel = fitcsvm(TR.train_Vols, TR.train_Vol_Labels, ...
            'KernelFunction', 'gaussian', 'KernelScale',best_K_value, 'BoxConstraint', best_C_value);
        [pred_label, score] = predict(anSVMModel, TE.test_Vols); %, testTarg);
        [~,~, ~, AUC] = perfcurve(TE.test_Vol_Labels,abs(score(:,2)),'Above_48.5_years');
        
        data_table = table(TE.test_Vol_Labels,tmp_test_data,score(:,1));
        writetable(data_table,strcat(outertraintestpath,num2str(worker_id),'_predictions.csv'));
        
        perf = classperf(TE.test_Vol_Labels,pred_label);

        Num_correctly_classified = perf.DiagnosticTable(1,1) + perf.DiagnosticTable(2,2);
        Num_incorrectly_classified = perf.DiagnosticTable(1,2) + perf.DiagnosticTable(2,1);
        T = table([worker_id,worker_id,best_p_Thres, size(TR.train_Vols,2),best_C_value, best_K_value,AUC, perf.CorrectRate, perf.Sensitivity, perf.Specificity, perf.PositivePredictiveValue,perf.NegativePredictiveValue,perf.NumberOfObservations,Num_correctly_classified,Num_incorrectly_classified,perf.DiagnosticTable(1,1),perf.DiagnosticTable(1,2),perf.DiagnosticTable(2,1),perf.DiagnosticTable(2,2),cellstr(strcat(num2str(best_p_Thres,'%0.10f'),',',num2str(best_C_value),',',num2str(best_K_value)))]); 
        writetable(T,strcat(outertraintestpath,num2str(worker_id),'_outertraintest.csv'),WriteMode='append');

else
    error(append('Best mask folder not found for outer fold ',num2str(worker_id)));
end


end_time = toc/3600;
append('Step6 outer train test processing complete for node ', num2str(worker_id), ' in ', num2str(end_time),' hours' )
fileID = fopen(append(runtimelogpath,'Step6_',num2str(worker_id),'_','runtime','_',num2str(round(end_time,5)),'_','.txt'),'w');
fprintf(fileID,append(num2str(round(end_time,5))));
fclose(fileID);


end 

exit



function [out] = use_eval(expression_text, tmp_data) %need tmp_data variable to resolve expression_text
    out = eval(expression_text);
end

function mask_module(ttestoutpath,outertraintestpath,worker_id,Imagefilenames, Vol_Labels, mask_folder, p_Thres, dataset_type)
    [x,y,z,~] = size(niftiread(Imagefilenames{1})); % for scalar momentum
    Vols = nan(size(Imagefilenames,1),x,y,z);
    
    for i = 1:size(Imagefilenames,1)
        Vol_tmp1 = niftiread(Imagefilenames{i});
        Vols(i,:,:,:) =squeeze(Vol_tmp1(:,:,:,1));% 4D for scalar momentum Vol1 =1, Vol2 = 2
    end
    
    Vols = reshape(Vols,size(Imagefilenames,1),x*y*z);
    [~] = apply_mask(ttestoutpath,outertraintestpath,worker_id,Vols, Vol_Labels,mask_folder, p_Thres, dataset_type,1);
end

function [out_Vols] = apply_mask(ttestoutpath,outertraintestpath,worker_id,Vols, Vol_Labels,mask_folder, p_Thres, datasettype, save_masked_volume_flag)
    load(strcat(ttestoutpath,'/',mask_folder,'/',num2str(p_Thres,'%0.10f'),'_binarymask.mat')); 

    if not(isfolder(strcat(outertraintestpath,'/', num2str(worker_id),'/', mask_folder)))
        mkdir(strcat(outertraintestpath,'/',  num2str(worker_id)));
        mkdir(append(outertraintestpath,'/', num2str(worker_id),'/', mask_folder))
    end
    copyfile(strcat(strcat(ttestoutpath,'/',mask_folder,'/',num2str(p_Thres,'%0.10f'),'_binarymask.mat')), strcat(outertraintestpath,'/',num2str(worker_id),'/',mask_folder,'/',num2str(p_Thres,'%0.10f'),'_binarymask.mat'))    
    mask = reshape(mask,1,size(mask,1)*size(mask,2)*size(mask,3));
    [~,ind]=find(mask);
    if strcmp(datasettype,'train')
        train_Vols = Vols(:,ind); % add normalisation here
        if save_masked_volume_flag == 1
            train_Vol_Labels = Vol_Labels;
            out_Vols = train_Vols;
            save(strcat(outertraintestpath,'/',num2str(worker_id),'/',mask_folder,'/',num2str(p_Thres,'%0.10f'),'_traindata.mat'),'train_Vols','train_Vol_Labels')
        end
    elseif strcmp(datasettype,'test')
        test_Vols = Vols(:,ind); 
         if save_masked_volume_flag == 1
             test_Vol_Labels = Vol_Labels;
             out_Vols = test_Vols;
             save(strcat(outertraintestpath,'/',num2str(worker_id),'/',mask_folder,'/',num2str(p_Thres,'%0.10f'),'_testdata.mat'),'test_Vols','test_Vol_Labels')
        end
    end
end
