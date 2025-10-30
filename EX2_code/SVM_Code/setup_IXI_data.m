#############################################
# File:   setup_IXI_data.m
#
# 
# Purpose:
# To load and structure the IXI dataset metadata (subject ID, age, sex) and associate each record with its corresponding MRI file path. This step also classifies participants into two age groups:
# Group 1: ≤48.5 years
# Group 2: >48.5 years
#
# Inputs:
# IXI.xls — demographic information
# MRI directories containing *.nii files
# 
# Outputs:
# IXI_table.csv — a master subject list used throughout the pipeline
#
# Author: PS Reel


IXI_data = readtable("C:\Local_Work\Data\IXI\IXI.xls");

files=dir('C:/Local_Work/Data/IXI/IXI-T1/*/a_c1w*.nii');
age_thres = 48.5;

for i = 1:size(files,1)
    extraction = extractBetween(files(i).name,'IXI', '-'); extraction = extraction(1);
    id = str2num(cell2mat(extraction));
    idx = find(IXI_data.IXI_ID == id); 
    if length(idx) > 1
        idx = idx(1);
    end
    
    if ~isempty(IXI_data(idx,:).AGE)
        files(i).P_Age=IXI_data(idx,:).AGE; 
        if files(i).P_Age <= age_thres
            files(i).Age_group = 'Below_48.5_years'
        else
            files(i).Age_group = 'Above_48.5_years'
        end
    else
        files(i).P_Age=NaN;
    end
    files(i).P_Age

    if ~isempty(IXI_data(idx,:).SEX_ID_1_m_2_f_)
        files(i).P_Sex=IXI_data(idx,:).SEX_ID_1_m_2_f_;
    else
        files(i).P_Sex=NaN;
    end
    files(i).P_Sex

    files(i).complete_path = strcat(files(i).folder ,'\',files(i).name);
end

files = struct2table(files);
%files.P_Age = cell2mat(files.P_Age)
writetable(files,'C:\Local_Work\Data\IXI\IXI_table.csv');
% delete NaN rows and non-related columns
data=readtable('C:\Local_Work\Data\IXI\IXI_table.xlsx');

file_names =string({files.name});
dir_names =string({files.folder});