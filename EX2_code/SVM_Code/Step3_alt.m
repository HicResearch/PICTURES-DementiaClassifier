#############################################
# File:   Step3_alt.m
#
# 
# Purpose:
# Generate t-test results using SPM [run on n workers]
#
# Author: PS Reel


tic
config_experiment
addpath(spmpath);

ttest_driver = readtable(strcat(driverpath,'ttest_driver.csv'));

for i = 1:size(ttest_driver,1)

worker_id = i;

append('worker_id = ', num2str(worker_id))

ttest_driver = readtable(strcat(driverpath,'ttest_driver.csv'));
index = ttest_driver.worker == worker_id;
tmp_ttest_driver = ttest_driver(index,:);

if not(isfolder(ttestoutpath))
    mkdir(ttestoutpath)
end

for i = 1:size(tmp_ttest_driver,1)
    tmp_outer = tmp_ttest_driver.outer_fold(i);
    tmp_inner  = tmp_ttest_driver.inner_fold(i);
    %tmp_p_Thres = tmp_ttest_driver.p_Thres(i);
    %tmp_index = tmp_ttest_driver.index(i);
    
    tmp_data = readtable(strcat(splitpath,num2str(tmp_outer),'_outersplitdetails.csv'));
    idx_train = use_eval(strcat('tmp_data.','fold_',num2str(tmp_inner),' == 1'), tmp_data);
    tmp_train_label = table2cell(tmp_data(idx_train,3));
    tmp_train_data = table2cell(tmp_data(idx_train,2));
    idx_test = use_eval(strcat('tmp_data.','fold_',num2str(tmp_inner),' == 0'), tmp_data);
    tmp_test_label = table2cell(tmp_data(idx_test,3));
    tmp_test_data = table2cell(tmp_data(idx_test,2));

    
    mask_folder = strcat(num2str(tmp_outer),'_',num2str(tmp_inner));

    if not(isfolder(strcat(ttestoutpath,'/',  mask_folder)))
        mkdir(strcat(ttestoutpath,'/',  mask_folder));
    end

    if ~isfile(strcat(ttestoutpath,'/',mask_folder,'/',mask_folder,'_ttest2_result.mat'))
        't-test folder does not exist. Running now'
        ttest2_module(projectpath, imagespath, spmpath,  ttestoutpath, tmp_train_data, tmp_train_label, conditions, p_Thres_range, tmp_inner, tmp_outer, mask_folder);
    else
        'SPM t-test folder exists'
    end

    mask_module(ttestoutpath,tmp_train_data, tmp_train_label, mask_folder, p_Thres_range,'train')
    mask_module(ttestoutpath,tmp_test_data, tmp_test_label, mask_folder, p_Thres_range,'test')
    
   
end
end_time = toc/3600;
append('Step3 ttest SPM processing complete for node ', num2str(worker_id), ' in ', num2str(end_time),' hours' )
fileID = fopen(append(runtimelogpath,'Step3_',num2str(worker_id),'_','runtime','_',num2str(round(end_time,5)),'_','.txt'),'w');
fprintf(fileID,append(num2str(round(end_time,5))));
fclose(fileID);

end
exit

function [] = ttest2_module(projectpath, imagespath, spmpath, ttestoutpath, allData, allLabel, conditions, p_Thres_range, kf,kFolds, mask_folder)
    addpath(projectpath);

    [x,y,z,~] = size(niftiread(allData{1})); % 4D for scalar momentum

    V1 = nan(nnz(strcmp(allLabel,conditions{1})),x,y,z);
    V2 = nan(nnz(strcmp(allLabel,conditions{2})),x,y,z);

    V1_i = 1;
    V2_i = 1;
    for i = 1:size(allLabel,1)
        if strcmp(allLabel{i},conditions{1})
            Vol_tmp1 = niftiread(allData{i});
            V1(V1_i,:,:,:) = squeeze(Vol_tmp1(:,:,:,1)); % 4D for scalar momentum for Vol1 = 1, Vol2 = 2
            V1_i = V1_i + 1;
	else 
            Vol_tmp2 = niftiread(allData{i});
            V2(V2_i,:,:,:) = squeeze(Vol_tmp2(:,:,:,1)); % 4D for scalar momentum for Vol1 = 1, Vol2 = 2
	    V2_i = V2_i + 1;
        end
    end
    
    [~,p_matrix] = ttest2(V1,V2);
    p_matrix = squeeze(p_matrix);
    save(strcat(ttestoutpath,'/',mask_folder,'/',mask_folder,'_ttest2_result.mat'),'p_matrix')
    
end

function mask_module(ttestoutpath,Imagefilenames, Vol_Labels, mask_folder, p_Thres_range, dataset_type)
    [x,y,z,~] = size(niftiread(Imagefilenames{1})); % 4D for scalar momentum
    Vols = nan(size(Imagefilenames,1),x,y,z);
    
    for i = 1:size(Imagefilenames,1)
        % 4D for scalar momentum
        Vol_tmp1 = niftiread(Imagefilenames{i});
        Vols(i,:,:,:) =squeeze(Vol_tmp1(:,:,:,2));% 4D for scalar momentum for Vol1 = 1, Vol2 = 2
    end
    
    Vols = reshape(Vols,size(Imagefilenames,1),x*y*z);
    
    for j = 1: size(p_Thres_range,2)
       create_mask(ttestoutpath,Vols, mask_folder, p_Thres_range(j), dataset_type);
    end

    for j = 1: size(p_Thres_range,2)
       [~] = apply_mask(ttestoutpath,Vols, Vol_Labels,mask_folder, p_Thres_range(j), dataset_type,1);
    end

end

function create_mask(ttestoutpath,Vols, mask_folder, p_Thres, datasettype)
    load(strcat(ttestoutpath,'/',mask_folder,'/',num2str(mask_folder),'_ttest2_result.mat')); % loads p_matrix variable
    mask = p_matrix <= p_Thres;
    save(strcat(ttestoutpath,'/',mask_folder,'/',num2str(p_Thres,'%.10f'),'_binarymask.mat'),'mask')
end

function [out_Vols] = apply_mask(ttestoutpath,Vols, Vol_Labels,mask_folder, p_Thres, datasettype, save_masked_volume_flag)
    load(strcat(ttestoutpath,'/',mask_folder,'/',num2str(p_Thres,'%.10f'),'_binarymask.mat')); % loads mask variable
    mask = reshape(mask,1,size(mask,1)*size(mask,2)*size(mask,3));
    [~,ind]=find(mask);
    if strcmp(datasettype,'train')
        train_Vols = Vols(:,ind); % add normalisation here
        if save_masked_volume_flag == 1
            train_Vol_Labels = Vol_Labels;
            out_Vols = train_Vols;
            save(strcat(ttestoutpath,'/',mask_folder,'/',num2str(p_Thres,'%.10f'),'_traindata.mat'),'train_Vols','train_Vol_Labels')
        end
    elseif strcmp(datasettype,'test')
        test_Vols = Vols(:,ind); 
         if save_masked_volume_flag == 1
             test_Vol_Labels = Vol_Labels;
             out_Vols = test_Vols;
             save(strcat(ttestoutpath,'/',mask_folder,'/',num2str(p_Thres,'%.10f'),'_testdata.mat'),'test_Vols','test_Vol_Labels')
        end
    end

 
end

function [out] = use_eval(expression_text, tmp_data) %need tmp_data variable to resolve expression_text
    out = eval(expression_text);
end

function [] = par_save(file_name,trainDataCParforROI,testDataCParforROI)
    save(eval('file_name'),'trainDataCParforROI','testDataCParforROI');
end

function [] = par_save1(file_name,tmp_train_label, tmp_test_label)
    save(eval('file_name'),'tmp_train_label', 'tmp_test_label');
end



