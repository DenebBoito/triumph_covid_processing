# #!/bin/bash

# Loop over all PATIENT subjects & do the preprocessing

# steps:
#  - motion correction
#  - anatomical brain extraction
#  - compute matrix for registration dwi2anatomical
#
# here we instead have a nice T1, so more straight forward processing applies


for i in /home/denbo78/test_folder_covid_preproc/p* ; do

    cd $i
    echo "Processing" $i
    
    # make a temporary directory for analysis
    mkdir analysis

    # copy the mdd_long & anatomical to this folder
    cp MDDlong/mdd_long.nii analysis
    cp Sag3DBRAVO*/sag*.nii analysis

    # copy the bvals & bvecs into the analysis directory
    cp -a /home/denbo78/Triumph_Git/mddLong_experimental_params/. analysis

    # now can work in the new folder
    cd analysis 

    # run the motion correction using mrtrix
    dwifslpreproc mdd_long.nii mdd_mc.mif -rpe_none -pe_dir AP -eddy_options "--data_is_shelled --slm=linear" -fslgrad bvecs.bvecs bvals.bvals

    # convert the mc data into nii & extract the rotated bvec & bval
    mrconvert mdd_mc.mif mdd_eddy.nii.gz -export_grad_fsl eddybvecs.txt eddybvals.txt

    # in case AFNI complains, we reorient the brain
    3dWarp -deoblique -prefix deobliqued.nii sag*.nii 

    # resample to convenient grid
    3dresample -dxyz 0.5 0.5 0.5 -input deobliqued.nii -prefix anat_resampled.nii

    # run brain extraction with AFNI 
    3dSkullStrip -input anat_resampled.nii -prefix skullstripped.nii -orig_vol -fill_hole 10

    # create a mean B0 for subsequent registration to anatomical
    dwiextract mdd_mc.mif - -bzero | mrmath - mean mean_bzero.mif -axis 3 
    mrconvert mean_bzero.mif mean_bzero.nii

    # create the mask to be used in QTI+?
    dwi2mask mdd_mc.mif -| maskfilter - dilate -| mrconvert - mdd_mask.nii

    # run the registration to get the transformation to be applied later
    epi_reg --epi=mean_bzero.nii --t1=anat_resampled.nii --t1brain=skullstripped.nii --out=out_epi_reg
    # this outputs a matrix file called out_epi_reg.mat which can be input to flirt to do the registration
    # flirt -ref flirted.nii -in map.nii -applyxfm -init out_epi_reg.mat -out reg_map


done