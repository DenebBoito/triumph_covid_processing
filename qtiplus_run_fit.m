% script to run qti+ on a patient folder
function qtiplus_run_fit()

%% load the nifti files and the header to be attached
% assumes that there is a mean b0 image called "mean_b0.nii"
% this file should have the correct sizes for voxel & pix dimesions
% but we need to tell that the datatype is double after processing
nii_h = niftiinfo('mean_bzero.nii');
nii_h.DataType = 'double';

% load the preprocessed data and the mask computed with MRTrix
data =  niftiread('mdd_eddy.nii');
mask =  niftiread('mdd_mask.nii');

%% define new xps based on new bvecs and bvals and b_delta
bval_fn = 'eddybvals.txt';
bvec_fn = 'eddybvecs.txt';
load('b_delta');
xps = mdm_xps_from_bval_bvec(bval_fn, bvec_fn, b_delta);

%% run qtiplus with default settings
[m, dps] = qtiplus_fit(data, xps.bt, 'mask', mask);

%% save m and dps in new folder
curr_fold = pwd;
mkdir('QTI+_Results')
cd('QTI+_Results')

% save model params & derived invariants
save('model', 'm')
save('invariants', 'dps')

% save QTI indices
qtiplus_invariants2nii(dps, nii_h);

%% return to previous folder
cd(curr_fold)

end