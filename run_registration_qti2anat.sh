# #!/bin/bash

# Loop over all subjects & do the registration of the QTI maps to anatomical image

for i in /home/denbo78/test_folder_covid_preproc/* ; do

    cd $i
    echo "Processing" $i

    # enter the analysis folder
    cd analysis

    # enter the QTI+_Results folder
    cd QTI+_Results

    # create & enter a new folder for the registered images
    mkdir registered

    # loop over the nifti files
    for j in *.nii ; do

    	# run the registration
    	filename="${j##*/}"
    	pre="reg_"
        outname="$pre$filename"

    	flirt -ref ../sag*.nii -in $filename -applyxfm -init ../out_epi_reg.mat -out $outname

    	# move to registered folder
    	mv $outname* registered

    done


	

done