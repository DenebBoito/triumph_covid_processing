# #!/bin/bash

cd ~/Desktop/Covid_subjs/p_subj_17/analysis
#cp sag*.nii QTI+_Results/
#cp out_epi_reg.mat QTI+_Results/
cd QTI+_Results
for i in *.nii ; do

    echo $i
    filename="${i##*/}"
    pre="reg_"
    outname="$pre$filename"

    echo $outname

    # run the registration
    flirt -ref ../sag*.nii -in $filename -applyxfm -init ../out_epi_reg.mat -out $outname

    # move volume to registered folder
    mv $outname* registered

done

    
