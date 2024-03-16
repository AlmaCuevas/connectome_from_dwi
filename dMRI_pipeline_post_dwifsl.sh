#!/bin/bash

#__author__ = 'AC'
#__contact__ = 'XXXX'
#__date__ = '10/2021'
#__version__ = '0.1'

# This is the post dwifslpreproc steps in the Diffusion pipeline

# Color codes
RED='\033[0;31m'
Cyan='\033[1;36m'
NC='\033[0m' # No Color
bold=$(tput bold)
normal=$(tput sgr0)

if [ $# -eq 0 ] ; then
	echo " "
	echo " "
	echo "Author: AC"
	echo " This is using edited functions, not the original given by Ai"
	echo " "
	echo " "
	echo "DESCRIPTION:"
	echo "	- Remove artifacts from the qc step and update the bvec and bval."
	echo "	- Fit the diffusion tensor model to the data and output related measures."
	echo "	- Co-register T1-weighted brain to DWI (b0) space."
	echo " "
	echo "PREREQUISITE:"
	echo "  	- dMRI_pipeline has been called on subject data."
	echo "	- Expects folder structure and naming convention from dMRI pipeline."
	echo "${bold}        - The volumes to delete (if any) should be on a 'outlier_vols.txt' file (separated by space) inside the qc folder${normal}"
	echo "	"
	echo "USAGE:"
	echo "	"
	echo "	dMRI_pipeline_post_dwifsl.sh < %s ID > < %s subjs_folder > < [optional] flag_FSL: 0 (default) || 1 >"
	echo " "
	echo "	%s ID		      		: Subject ID that prepends all output"
	echo "	%s subjs_folder		: Root subjects folder created after calling a qc prep"
	echo "	[%d flag_FSL]        		: Processing option, [0 || 1]"
	echo "						0 = Not show main results"
        echo "		                           	1 = Open mrview (Eigenvector) and FSLeyes (Coregistration between T1w and b0)"
	echo " "
	echo "  	*The out will be save in the subjs_folder/out_logs*"
	echo "	*Include full paths*"
	echo "	"
	echo " "
	exit 1
fi

if [[ $# -lt 2 || $# -gt 3 ]]; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: $# arguments entered to call dMRI_pipeline_post_dwifsl.sh when expecting 2 or 3.${NC}"
	dMRI_pipeline_post_dwifsl.sh
	exit 1
fi

currPath=`pwd`

ID=$1
subjectsPath=$2
flag_FSL=${3:-0}

subjPath=$subjectsPath/${ID}
diffPath=${subjPath}/Diffusion/Preproc_files
preEddyPath=${diffPath}/PreEddy
eddyPath=${diffPath}/Eddy
freesurferPath=${subjPath}/Freesurfer
transformPath=${subjPath}/Diffusion/Preproc_files/Transforms
DTIpath=${subjPath}/Diffusion/DTI

mkdir -p $subjectsPath/out_logs # Save in out_logs
( # Everything would be save from now on

if [ ! -d $subjPath ]; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: $subjPath does not exist. Cannot continue.${NC}"
	dMRI_pipeline_post_dwifsl.sh
	exit 1
elif [ ! -d $preEddyPath ]; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: $preEddyPath does not exist. Cannot continue."
	echo -e "		Have you called dMRI_pipeline_prep_files.sh?${NC}"
	dMRI_pipeline_post_dwifsl.sh
	exit 1
elif [ ! -f ${eddyPath}/${ID}_unbiased.mif ] ; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: ${eddyPath}/${ID}_unbiased.mif does not exist. Cannot continue."
	echo -e "		Have you called dMRI_pipeline_dwifsl.sh?${NC}"
	dMRI_pipeline_post_dwifsl.sh
	exit 1
elif [ ! -d $freesurferPath ] ; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: ${freesurferPath} does not exist. Cannot continue."
	echo -e "		Have you called qc_freesurfer.sh or run recon_all?${NC}"
	dMRI_pipeline_post_dwifsl.sh 
	exit 1
fi

mkdir -p ${DTIpath}
echo "${bold} Friendly reminder that the volumes to delete (if any) should be on a 'outlier_vols' file (separated by space) inside the qc folder${normal}"
		echo " "
		echo " "
echo -e "${Cyan}================================================================="
echo " Remove artifacts from the qc step and update the bvec and bval ${ID} ...."
echo -e "=================================================================${NC}"

if [ ! -f ${eddyPath}/outlier_vols ]; then # If the file doesn't exist
	echo " "
	echo "No volumes with artifacts to remove from QCd DWI data, just copy and renaming files..."
	echo " "
	echo "cp ${eddyPath}/${ID}_unbiased.mif ${diffPath}/${ID}_DWI_QCd.mif"		
	cp ${eddyPath}/${ID}_unbiased.mif ${diffPath}/${ID}_DWI_QCd.mif 

else # If there is an 'outlier_vols' file, then remove them.
	echo "Flipping the bvec from [3(x,y,z) x nDirs] to [nDirs x 3]..." #bval does not need rotation
	echo " "
	echo "flip_bvec_matrix_edited.py ${eddyPath}/${ID}_eddy.bvec 0 ${DTIpath}/${ID}_rotated.bvec"
	flip_bvec_matrix_edited.py ${eddyPath}/${ID}_eddy.bvec 0 ${DTIpath}/${ID}_rotated.bvec
	echo " "
	
	echo "Removing volumes in ${eddyPath}/outlier_vols from post-eddy files..."
	# Remove vols from dwi. This will also output b-value file in format to convert into .mif
	echo " "
	echo "cd ${diffPath}"
	cd ${diffPath}
	echo " "
	#bcas example: dwi_remove_vols.py 010825_postQC_remove_vols.txt 010825_eddy.nii.gz 010825_eddy.eddy_rotated_bvecs_rotated.bvec 010825_DWI_fsl.bval TESTOUT
	echo "dwi_remove_vols_edited.py ${eddyPath}/outlier_vols ${eddyPath}/${ID}_unbiased.nii.gz ${DTIpath}/${ID}_rotated.bvec ${eddyPath}/${ID}_eddy.bval ${ID}_DWI_QCd"
	dwi_remove_vols_edited.py ${eddyPath}/outlier_vols ${eddyPath}/${ID}_unbiased.nii.gz ${DTIpath}/${ID}_rotated.bvec ${eddyPath}/${ID}_eddy.bval ${ID}_DWI_QCd # do not add the folder or .nii.gz, the python code crash, just add de cd before calling it.
	# outputs ${ID}_DWI_QCd.nii.gz/.bvec/.bval
	echo " "
	echo "Convert from .nii.gz to .mif"
	echo " "
	echo "mrconvert ${ID}_DWI_QCd.nii.gz -fslgrad ${ID}_DWI_QCd.bvec ${ID}_DWI_QCd.bval ${ID}_DWI_QCd.mif -force"
	mrconvert ${ID}_DWI_QCd.nii.gz -fslgrad ${ID}_DWI_QCd.bvec ${ID}_DWI_QCd.bval ${ID}_DWI_QCd.mif -force
	# outputs ${ID}_DWI_QCd.mif
fi

#echo " " This was done in a different script dt_correction.sh, but could have done here instead, just change the output names
#echo " Correct the bvecs direction..." # With this the dt gradient is corrected
#echo "dwigradcheck ${diffPath}/${ID}_DWI_QCd.mif -export_grad_mrtrix ${DTIpath}/${ID}_fixed_bvecs.txt"
#dwigradcheck ${diffPath}/${ID}_DWI_QCd.mif -export_grad_mrtrix ${DTIpath}/${ID}_fixed_bvecs.txt
#echo " "
#echo "mrconvert ${diffPath}/${ID}_DWI_QCd.mif ${DTIpath}/${ID}_DWI_QCd_fixed.mif -grad ${DTIpath}/${ID}_fixed_bvecs.txt"
#mrconvert ${diffPath}/${ID}_DWI_QCd.mif ${DTIpath}/${ID}_DWI_QCd_fixed.mif -grad ${DTIpath}/${ID}_fixed_bvecs.txt

echo " "
echo -e "${Cyan}================================================================="
echo " Fit the diffusion tensor model to the data and output related measures ${ID} ..."
echo -e "=================================================================${NC}"
# Compute brain mask, fit tensor and get adc/fa maps

echo " "
echo " Creating new b0 mask..." # To improve the mask after the unbiased.
echo " "
echo " dwi2mask ${diffPath}/${ID}_DWI_QCd.mif ${diffPath}/${ID}_b0_Eddy_brain_mask.nii.gz -force"
dwi2mask ${diffPath}/${ID}_DWI_QCd.mif ${diffPath}/${ID}_b0_Eddy_brain_mask.nii.gz -force
echo " "
echo "Fitting diffusion tensor and getting diffusion maps..."
echo " "
echo "dwi2tensor -mask ${diffPath}/${ID}_b0_Eddy_brain_mask.nii.gz ${diffPath}/${ID}_DWI_QCd.mif ${DTIpath}/${ID}_dt.mif -force"
dwi2tensor -mask ${diffPath}/${ID}_b0_Eddy_brain_mask.nii.gz ${diffPath}/${ID}_DWI_QCd.mif ${DTIpath}/${ID}_dt.mif -force
echo " "
echo "tensor2metric -mask ${diffPath}/${ID}_b0_Eddy_brain_mask.nii.gz -adc ${DTIpath}/${ID}_md.mif -fa ${DTIpath}/${ID}_fa.mif ${DTIpath}/${ID}_dt.mif -force"
tensor2metric -mask ${diffPath}/${ID}_b0_Eddy_brain_mask.nii.gz -adc ${DTIpath}/${ID}_md.mif -fa ${DTIpath}/${ID}_fa.mif ${DTIpath}/${ID}_dt.mif -force
# outputs ${ID}_fa.mif, ${ID}_md.mif, ${ID}_dt.mif
echo " "


echo -e "${Cyan}================================================================="
echo " Co-register T1-weighted brain to DWI (b0) space ${ID} ...."
echo -e "=================================================================${NC}"

# Calculate post-QC mean of all b0s image
echo "Compute post-QC mean b0 volume, ${ID}_aveB0.mif/.nii.gz"
echo " "
echo "dwiextract ${diffPath}/${ID}_DWI_QCd.mif - -bzero | mrmath - mean ${diffPath}/${ID}_aveb0.mif -axis 3 -force" #'-' denotes that the output willl be piped into the next command, which follows after '|'. Like this, no additional output files are created. '-axis 3' denotes that the mean image will be calculated along the third axis
dwiextract ${diffPath}/${ID}_DWI_QCd.mif - -bzero | mrmath - mean ${diffPath}/${ID}_aveb0.mif -axis 3 -force
echo "mrconvert ${diffPath}/${ID}_aveb0.mif ${diffPath}/${ID}_aveb0.nii.gz -force"
mrconvert ${diffPath}/${ID}_aveb0.mif ${diffPath}/${ID}_aveb0.nii.gz -force
# outputs ${ID}_aveb0.mif/.nii.gz

# Coregister T1-Weighted and DWI/b0 data
echo " "
echo "Creating folder ${transformPath}..."
echo " "
mkdir -p ${transformPath}

echo "mri_convert ${freesurferPath}/mri/brain.mgz ${freesurferPath}/mri/brain.nii.gz"
mri_convert ${freesurferPath}/mri/brain.mgz ${freesurferPath}/mri/brain.nii.gz
# outputs brain.nii.gz in the freesurfer folder

cd ${diffPath}

# The following transforms were not used

# echo " "
# echo "Register b0 to T1"
# echo "reg_aladin -ref ${freesurferPath}/mri/brain.nii.gz -flo ${ID}_aveb0.nii.gz -res ${transformPath}/niftyreg_affine_b02T1W.nii.gz -aff ${transformPath}/niftyreg_affineTransform_b02T1W.txt"
# reg_aladin -ref ${freesurferPath}/mri/brain.nii.gz -flo ${ID}_aveb0.nii.gz -res ${transformPath}/niftyreg_affine_b02T1W.nii.gz -aff ${transformPath}/niftyreg_affineTransform_b02T1W.txt
# outputs niftyreg_affineTransform_b02T1W.txt

# echo " "
# echo "Invert transform"
# echo "reg_transform -ref ${ID}_aveb0.nii.gz -invAffine ${transformPath}/niftyreg_affineTransform_b02T1W.txt ${transformPath}/niftyreg_affineTransform_b02T1W_Inv.txt"
# reg_transform -ref ${ID}_aveb0.nii.gz -invAffine ${transformPath}/niftyreg_affineTransform_b02T1W.txt ${transformPath}/niftyreg_affineTransform_b02T1W_Inv.txt
# outputs niftyreg_affineTransform_b02T1W_Inv.txt
# echo " "
# echo "Apply inverse transform to T1W"
# echo "reg_resample -target ${ID}_aveb0.nii.gz -source ${freesurferPath}/mri/brain.nii.gz -res ${ID}_T1W2b0.nii.gz -aff ${transformPath}/niftyreg_affineTransform_b02T1W_Inv.txt"
# reg_resample -target ${ID}_aveb0.nii.gz -source ${freesurferPath}/mri/brain.nii.gz -res ${ID}_T1W2b0.nii.gz -aff ${transformPath}/niftyreg_affineTransform_b02T1W_Inv.txt
# outputs ${ID}_T1W2b0.nii.gz

# Visualize in FSL
if [ $flag_FSL != 0 ]; then
	echo -e "${Cyan}================================================================="
	echo " Check 1) principle eigenvector direction using Mrview, do the b-vectors need flipping/switching? and 2) coregistration between T1-W and b0 volumes in FSLeyes ${ID} ...."
	echo -e "=================================================================${NC}"
	echo "fsleyes ${diffPath}/${ID}_T1W2b0.nii.gz ${diffPath}/${ID}_aveb0.nii.gz ${diffPath}/${ID}_DWI_QCd.nii.gz &"
	fsleyes ${diffPath}/${ID}_T1W2b0.nii.gz ${diffPath}/${ID}_aveb0.nii.gz ${diffPath}/${ID}_DWI_QCd.nii.gz &
	
	echo ""
	echo "mrview ${ID}_fa.mif -odf.load_tensor ${ID}_dt.mif &"
	exit 1
fi
echo ""
echo -e "${Cyan}==================================================================="
echo "dMRI_pipeline_post_dwifsl.sh completed."
echo " "
echo ">>>> QC check point:"
echo "		B1 corrected output ${ID}_unbiased.mif output, and ${ID}_eddy_brain_mask.mif"
echo " "
echo "OUTPUT (in (${diffPath}):"
echo "${ID}_b0_Eddy_brain_mask.nii.gz		- Final mask to correct the unbiased result"
echo "${ID}_DWI_QCd.mif				- Processed and QC'd final DWI volume ready for analyses."
echo "${ID}_DWI_QCd.nii.gz / .bvec / .bval		- If volumes were removed from DWI, these files will be output."
echo "${ID}_aveb0.mif/.nii.gz			- Mean b0 from all b=0 volumes in ${ID}_DWI_QCd.mif"
echo "${ID}_T1W2b0.nii.gz				- T1W brain image in b0 space. (see below)"
echo "	"
echo "DTI						- Directory created."
echo "DTI/${ID}_dt.mif				- Fitted diffusion tensor."
echo "DTI/${ID}_fa.mif				- FA map"
echo "DTI/${ID}_md.mif				- MD map"

# echo "	"
# echo "Transforms					- Directory created."
# echo "Transforms/niftyreg_affine_b02T1W.nii.gz	- ${ID}_aveb0.mif -> T1W_brain image."
# echo "Transforms/niftyreg_affineTransform_b02T1W.txt	- The above's transformation matrix."
# echo "Transforms/niftyreg_affineTransform_b02T1W_Inv.txt- The above's inversed transformation matrix."
echo "	"
echo "In ${freesurferPath}"
echo -e "brain.nii.gz					- Conversion to .nii.gz of brain.mgz${NC}"


cd ${currPath}
# Now pause and QC check output!
 ) 2>&1 | tee $subjectsPath/out_logs/${ID}_post_dwifsl.out




