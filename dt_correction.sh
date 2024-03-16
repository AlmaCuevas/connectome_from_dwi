#!/bin/bash

#__author__ = 'AC'
#__contact__ = 'XXXX'
#__date__ = '11/2021'
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
	echo " "
	echo " "
	echo "DESCRIPTION:"
	echo "	Correct the direction of the dt."
	echo " "
	echo "PREREQUISITE:"
	echo "  	- dMRI_pipeline has been called on subject data."
	echo "	- Expects folder structure and naming convention from dMRI pipeline."
	echo "${bold}        - The volumes to delete (if any) should be on a 'outlier_vols.txt' file (separated by space) inside the qc folder${normal}"
	echo "	"
	echo "USAGE:"
	echo "	"
	echo "	dt_correction.sh < %s ID > < %s subjs_folder > < [optional] flag_FSL: 0 (default) || 1 >"
	echo " "
	echo "	%s ID		      		: Subject ID that prepends all output"
	echo "	%s subjs_folder		: Root subjects folder created after calling a qc prep"
	echo " "
	echo "  	*The out will be save in the subjs_folder/out_logs*"
	echo "	*Include full paths*"
	echo "	"
	echo " "
	exit 1
fi

if [ $# -ne 2 ]; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: $# arguments entered when expecting 2.${NC}"
	dt_correction.sh
	exit 1
fi

currPath=`pwd`

ID=$1
subjectsPath=$2


subjPath=$subjectsPath/${ID}
diffPath=${subjPath}/Diffusion/Preproc_files
preEddyPath=${diffPath}/PreEddy
eddyPath=${diffPath}/Eddy
freesurferPath=${subjPath}/Freesurfer
transformPath=${subjPath}/Diffusion/Preproc_files/Transforms
DTIpath=${subjPath}/Diffusion/DTI_corrected

mkdir -p ${DTIpath} # Correction path

mkdir -p $subjectsPath/out_logs # Save in out_logs
( # Everything would be save from now on

echo " "
echo " Correct the bvecs direction..."
echo "dwigradcheck ${diffPath}/${ID}_DWI_QCd.mif -export_grad_mrtrix ${DTIpath}/${ID}_fixed_bvecs.txt"
dwigradcheck ${diffPath}/${ID}_DWI_QCd.mif -export_grad_mrtrix ${DTIpath}/${ID}_fixed_bvecs.txt

echo " "
echo "mrconvert ${diffPath}/${ID}_DWI_QCd.mif ${DTIpath}/${ID}_DWI_QCd_fixed.mif -grad ${DTIpath}/${ID}_fixed_bvecs.txt  -force"
mrconvert ${diffPath}/${ID}_DWI_QCd.mif ${DTIpath}/${ID}_DWI_QCd_fixed.mif -grad ${DTIpath}/${ID}_fixed_bvecs.txt -force

# outputs ${ID}_fixed_bvecs.txt
echo " "
echo -e "${Cyan}================================================================="
echo " Fit the diffusion tensor model to the data and output related measures ${ID} ...."
echo -e "=================================================================${NC}"

echo "Fitting diffusion tensor and getting diffusion maps..."
echo " "
echo "dwi2tensor -mask ${diffPath}/${ID}_b0_Eddy_brain_mask.nii.gz ${DTIpath}/${ID}_DWI_QCd_fixed.mif ${DTIpath}/${ID}_dt_fixed.mif -force"
dwi2tensor -mask ${diffPath}/${ID}_b0_Eddy_brain_mask.nii.gz ${DTIpath}/${ID}_DWI_QCd_fixed.mif ${DTIpath}/${ID}_dt_fixed.mif -force
echo " "
echo "tensor2metric -mask ${diffPath}/${ID}_b0_Eddy_brain_mask.nii.gz -adc ${DTIpath}/${ID}_md_fixed.mif -fa ${DTIpath}/${ID}_fa_fixed.mif ${DTIpath}/${ID}_dt_fixed.mif -force"
tensor2metric -mask ${diffPath}/${ID}_b0_Eddy_brain_mask.nii.gz -adc ${DTIpath}/${ID}_md_fixed.mif -fa ${DTIpath}/${ID}_fa_fixed.mif ${DTIpath}/${ID}_dt_fixed.mif -force
# outputs ${ID}_fa_fixed.mif, ${ID}_md_fixed.mif, ${ID}_dt_fixed.mif
echo " "

cd ${currPath}
# Now pause and QC check output!
 ) 2>&1 | tee $subjectsPath/out_logs/${ID}_dt_correction.out

