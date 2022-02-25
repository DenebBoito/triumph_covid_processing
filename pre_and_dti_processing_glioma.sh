# #!/bin/bash

# script to preprocess the Glioma Study Group

# Loop over all subjects & do the preprocessing & diffusion tensor fitting

# steps:
# preprocessing:
#  - motion correction
#  - anatomical brain extraction
#  - compute matrix for registration dwi2anatomical
#  
# processing:
# - create a brain mask
# - tensor fitting (WLS and IWLS)
# - metrics computations
#
#
# Updated: 25/02/2022


for i in /folder* ; do

    cd $i
    echo "Processing" $i
    
    # convert to mif format & include gradient info in header
    cd *DTI*
    mrconvert *DTI*.nii.gz dwi.mif -fslgrad *DTI*.bvec *DTI*.bval

    # make a temporary directory for analysis
    cd ..
    mkdir dti_analysis

    # copy the mdd_long & anatomical to this folder
    cp *T1*/*T1*.nii.gz analysis
    cp *DTI*/dwi.mif analysis

    # now can work in the new folder
    cd dti_analysis 

    # run the motion correction using mrtrix
    dwifslpreproc dwi.mif dwi_mc.mif -rpe_none -pe_dir PA -eddy_options "--data_is_shelled --slm=linear" 

    # create a mask
    dwi2mask dwi_mc.mif dwi_mask.nii

    # run the tensor fit
    dwi2tensor -mask dwi_mask.nii -iter 4 dwi_mc.mif dti.mif

    # extract the metrics
    tensor2metric -adc adc.nii -fa fa.nii 

    ##### preprare the anatomical for registration #####
    # resample T1 to convenient grid
    3dresample -dxyz 0.5 0.5 0.5 -input *T1*.nii.gz -prefix T1_resampled.nii

    # run brain extraction with AFNI 
    3dSkullStrip -input T1_resampled.nii -prefix skullstripped.nii -orig_vol -fill_hole 10

    # create a mean B0 for subsequent registration to anatomical
    dwiextract mdd_mc.mif - -bzero | mrconvert bzero.nii 

    # run the registration to get the transformation to be applied later
    epi_reg --epi=bzero.nii --t1=T1_resampled.nii --t1brain=skullstripped.nii --out=out_epi_reg

    # register the FA and ADC maps to T1
    flirt -ref T1_resampled.nii -in fa.nii -applyxfm -init out_epi_reg.mat -out fa_reg
    flirt -ref T1_resampled.nii -in adc.nii -applyxfm -init out_epi_reg.mat -out adc_reg


done