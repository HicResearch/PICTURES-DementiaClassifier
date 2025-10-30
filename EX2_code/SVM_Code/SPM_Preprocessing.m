#############################################
# File:   SPM_preprocessing.m
#
# 
# Purpose:
# To setup SPM software
#
# Author: PS Reel

#setup SPM software
files=dir('C:/Local_Work/Data/IXI/IXI-T1/*/*.nii');
file_names =string({files.name});
dir_names =string({files.folder});

%P = 2;
%myCluster = parcluster('local')
%myCluster.NumWorkers = P;
%saveProfile(myCluster);
%parpool(P);
tic
for i = 1:size(file_names,2)
    run_parallel_preprocessing(strcat(dir_names{i},'/',file_names{i}));
end

end_time = toc/3600
'preprocessing complete'

function run_parallel_preprocessing(full_file_path)
    spm_jobman('initcfg');
    
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {full_file_path};
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {full_file_path};%'/home/ubuntu/Desktop/test_image/sffa0134483-090502-00001-00025-1.nii'};
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {'C:/Local_Work/EX2_code/spm12/spm12/tpm/TPM.nii'};
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70
                                                                 78 76 85];
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = 'w';
    matlabbatch{2}.spm.spatial.preproc.channel.vols(1) = cfg_dep('Normalise: Estimate & Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
    matlabbatch{2}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{2}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{2}.spm.spatial.preproc.channel.write = [0 0];
    matlabbatch{2}.spm.spatial.preproc.tissue(1).tpm = {'C:/Local_Work/EX2_code/spm12/spm12/tpm/TPM.nii,1'};
    matlabbatch{2}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{2}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{2}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{2}.spm.spatial.preproc.tissue(2).tpm = {'C:/Local_Work/EX2_code/spm12/spm12/tpm/TPM.nii,2'};
    matlabbatch{2}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{2}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{2}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{2}.spm.spatial.preproc.tissue(3).tpm = {'C:/Local_Work/EX2_code/spm12/spm12/tpm/TPM.nii,3'};
    matlabbatch{2}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{2}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{2}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{2}.spm.spatial.preproc.tissue(4).tpm = {'C:/Local_Work/EX2_code/spm12/spm12/tpm/TPM.nii,4'};
    matlabbatch{2}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{2}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{2}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{2}.spm.spatial.preproc.tissue(5).tpm = {'C:/Local_Work/EX2_code/spm12/spm12/tpm/TPM.nii,5'};
    matlabbatch{2}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{2}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{2}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{2}.spm.spatial.preproc.tissue(6).tpm = {'C:/Local_Work/EX2_code/spm12/spm12/tpm/TPM.nii,6'};
    matlabbatch{2}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{2}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{2}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{2}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{2}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{2}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{2}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{2}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{2}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{2}.spm.spatial.preproc.warp.write = [0 1];
    matlabbatch{2}.spm.spatial.preproc.warp.vox = NaN;
    matlabbatch{2}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                                  NaN NaN NaN];
    matlabbatch{3}.spm.tools.shoot.warp.images{1}(1) = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
    matlabbatch{3}.spm.tools.shoot.warp.images{2}(1) = cfg_dep('Segment: c2 Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{2}, '.','c', '()',{':'}));
    matlabbatch{4}.spm.tools.shoot.kernfun.scalmom.template(1) = cfg_dep('Run Shooting (create Templates): Template (4)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','template', '()',{5}));
    matlabbatch{4}.spm.tools.shoot.kernfun.scalmom.images{1}(1) = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
    matlabbatch{4}.spm.tools.shoot.kernfun.scalmom.images{2}(1) = cfg_dep('Segment: c2 Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{2}, '.','c', '()',{':'}));
    matlabbatch{4}.spm.tools.shoot.kernfun.scalmom.deformations(1) = cfg_dep('Run Shooting (create Templates): Deformation Fields', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','def', '()',{':'}));
    matlabbatch{4}.spm.tools.shoot.kernfun.scalmom.jacobians(1) = cfg_dep('Run Shooting (create Templates): Jacobian Fields', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','jac', '()',{':'}));
    matlabbatch{4}.spm.tools.shoot.kernfun.scalmom.fwhm = 12;
    spm_jobman('run',matlabbatch); clear matlabbatch;
end