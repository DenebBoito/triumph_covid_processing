% test writing qti invariants to nifti file and then register to anatomical
%

clear
data = niftiread('mdd_long.nii');
nii_h = niftiinfo('mdd_long.nii');
nii_h.ImageSize = [80,80,39];
nii_h.PixelDimensions = [3,3,4];
load('xps GE long')

[m,dps] = qtiplus_fit(data,xps.bt);

