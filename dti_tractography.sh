#!/bin/bash

#__author__ = 'AC'
#__contact__ = 'XXXX'
#__date__ = '12/2021'
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
	echo "DESCRIPTION: (following Batman instructions)"
	echo "	- Preparing Anatomically Constrained Tractography (ACT)."
	echo "	- Transform matrix, with MRTRIX"
	echo "	- White Matter (WM) mask conversion"
	echo "	- DTI tractography generation of .tck"
	echo "	- Creation of subsample for visualization"
	echo "	- Conversion of .tck to .trk for 3D visualization"
	echo " "
	echo "PREREQUISITE:"
	echo "  	- dMRI_pipeline has been called on subject data."
	echo "	- Expects folder structure and naming convention from dMRI pipeline."
	echo "	"
	echo "USAGE:"
	echo "	"
	echo "	dti_tractography.sh < %s subjs_folder > < %s ID >"
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
	dti_tractography.sh
	exit 1
fi

currPath=`pwd`

subjectsPath=${1:-/root_folder/here/}
ID=$2

subjPath=$subjectsPath/${ID}
diffPath=${subjPath}/Diffusion/Preproc_files
preEddyPath=${diffPath}/PreEddy
eddyPath=${diffPath}/Eddy
freesurferPath=${subjPath}/Freesurfer
DTIpath=${subjPath}/Diffusion/DTI_corrected
TractPath=${subjPath}/Diffusion/Tractography
lut=/root_folder/here/FreeSurferColorLUT.txt
mkdir -p ${TractPath}


mkdir -p $subjectsPath/out_logs # Save in out_logs
( # Everything would be save from now on

if [ ! -d $subjPath ]; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: $subjPath does not exist. Cannot continue.${NC}"
	dti_tractography.sh
	exit 1
elif [ ! -d $DTIpath ]; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: $DTIpath does not exist. Cannot continue.${NC}"
	dti_tractography.sh
	exit 1
fi

echo -e "${Cyan}================================================================="
echo "	Preparing Anatomically Constrained Tractography (ACT) ${ID} ..."
echo -e "=================================================================${NC}"
echo ""

echo "${bold}mrconvert ${freesurferPath}/mri/brain.mgz ${TractPath}/${ID}_maskT1.mif${normal}"
mrconvert ${freesurferPath}/mri/brain.mgz ${TractPath}/${ID}_maskT1.mif
echo ""
echo "	5tt creation, with MRTRIX"

echo "${bold}5ttgen fsl -premasked ${TractPath}/${ID}_maskT1.mif ${TractPath}/${ID}_5tt.mif -force${normal}"
5ttgen fsl -premasked ${TractPath}/${ID}_maskT1.mif ${TractPath}/${ID}_5tt.mif -force
# outputs ${ID}_maskT1.mif and ID_5tt.mif (five-tissue-type)
echo ""


echo -e "${Cyan}================================================================="
echo "	Transform matrix, with MRTRIX ${ID} ..."
echo -e "=================================================================${NC}"
echo ""

# flirt is the main program that performs affine registration. The main options are: an input (-in) and a reference (-ref) volume; the calculated affine transformation that registers the input to the reference which is saved as a 4x4 affine matrix (-omat); and output volume (-out) where the transform is applied to the input volume to align it with the reference volume. 
echo "${bold}flirt -in ${diffPath}/${ID}_aveb0.nii.gz -ref ${freesurferPath}/mri/brain.nii.gz -dof 6 -omat ${TractPath}/${ID}_dwi2t1_fsl.mat${normal}" # with DWI b0's average mask
flirt -in ${diffPath}/${ID}_aveb0.nii.gz -ref ${freesurferPath}/mri/brain.nii.gz -dof 6 -omat ${TractPath}/${ID}_dwi2t1_fsl.mat
echo "${bold}transformconvert ${TractPath}/${ID}_dwi2t1_fsl.mat ${diffPath}/${ID}_aveb0.nii.gz ${freesurferPath}/mri/brain.nii.gz flirt_import ${TractPath}/${ID}_dwi2t1_mrtrix.txt -force${normal}"
transformconvert ${TractPath}/${ID}_dwi2t1_fsl.mat ${diffPath}/${ID}_aveb0.nii.gz ${freesurferPath}/mri/brain.nii.gz flirt_import ${TractPath}/${ID}_dwi2t1_mrtrix.txt -force
# outputs ${ID}_dwi2t1_fsl.mat and ${ID}_dwi2t1_mrtrix.txt
echo ""

echo "	Co-registration, with MRTRIX"
echo "${bold}mrtransform ${freesurferPath}/mri/brain.nii.gz -linear ${TractPath}/${ID}_dwi2t1_mrtrix.txt -inverse ${TractPath}/${ID}_maskT1_coreg.mif -force${normal}"
mrtransform ${freesurferPath}/mri/brain.nii.gz -linear ${TractPath}/${ID}_dwi2t1_mrtrix.txt -inverse ${TractPath}/${ID}_maskT1_coreg.mif -force
# outputs ${ID}_maskT1_coreg.mif

echo "${bold}mrtransform ${TractPath}/${ID}_5tt.mif -linear ${TractPath}/${ID}_dwi2t1_mrtrix.txt -inverse ${TractPath}/${ID}_5tt_coreg.mif -force${normal}"
mrtransform ${TractPath}/${ID}_5tt.mif -linear ${TractPath}/${ID}_dwi2t1_mrtrix.txt -inverse ${TractPath}/${ID}_5tt_coreg.mif -force
# outputs ${ID}_5tt_coreg.mif
echo ""

echo "${bold}5tt2gmwmi ${TractPath}/${ID}_5tt_coreg.mif ${TractPath}/${ID}_gmwmSeed.mif -force${normal}"
5tt2gmwmi ${TractPath}/${ID}_5tt_coreg.mif ${TractPath}/${ID}_gmwmSeed.mif -force
# outputs ${TractPath}/${ID}_gmwmSeed.mif
echo ""

# wm image, This doesn't work as expected so it was omitted
#echo -e "${Cyan}================================================================="
#echo "	Creating the white matter mask ${ID} ..."
#echo -e "=================================================================${NC}"
#echo ""
#echo "White Matter mask"
#echo "${bold}mrconvert -coord 3 2 ${TractPath}/${ID}_5tt_coreg.mif ${TractPath}/${ID}_5tt_coreg_wm.mif${normal}"
#mrconvert -coord 3 2 ${TractPath}/${ID}_5tt_coreg.mif ${TractPath}/${ID}_5tt_coreg_wm.mif
#
#echo "${bold}mrconvert ${TractPath}/${ID}_5tt_coreg_wm.mif ${TractPath}/${ID}_5tt_coreg_wm.nii.gz${normal}"
#mrconvert ${TractPath}/${ID}_5tt_coreg_wm.mif ${TractPath}/${ID}_5tt_coreg_wm.nii.gz
#
#echo "Convert to binary mask"
##threshold your image at this threshold to create a binary mask
#thresh_it=`fslstats ${TractPath}/${ID}_5tt_coreg_wm.nii.gz -P 15`
#echo "${bold}fslmaths ${TractPath}/${ID}_5tt_coreg_wm.nii.gz -thr $thresh_it -bin ${TractPath}/${ID}_5tt_coreg_wm_binary.nii.gz${normal}"
#fslmaths ${TractPath}/${ID}_5tt_coreg_wm.nii.gz -thr $thresh_it -bin ${TractPath}/${ID}_5tt_coreg_wm_binary.nii.gz
#
#echo "${bold}mrconvert ${TractPath}/${ID}_5tt_coreg_wm_binary.nii.gz ${TractPath}/${ID}_5tt_coreg_wm_binary.mif${normal}"
#mrconvert ${TractPath}/${ID}_5tt_coreg_wm_binary.nii.gz ${TractPath}/${ID}_5tt_coreg_wm_binary.mif

echo -e "${Cyan}================================================================="
echo "	Creating the streamlines ${ID} ..."
echo -e "=================================================================${NC}"
echo ""
# gmwmi
echo "${bold}tckgen -algorithm Tensor_Prob -act ${TractPath}/${ID}_5tt_coreg.mif -crop_at_gmwmi -maxlength 250 -seed_gmwmi ${TractPath}/${ID}_gmwmSeed.mif -select 10000000 ${DTIpath}/${ID}_DWI_QCd_fixed.mif ${TractPath}/${ID}_gmwmi.tck${normal}"
tckgen -algorithm Tensor_Prob -act ${TractPath}/${ID}_5tt_coreg.mif -crop_at_gmwmi -maxlength 250 -seed_gmwmi ${TractPath}/${ID}_gmwmSeed.mif -select 10000000 ${DTIpath}/${ID}_DWI_QCd_fixed.mif ${TractPath}/${ID}_gmwmi.tck
# wm image, This doesn't work as expected so it was omitted
#echo "${bold}tckgen -algorithm Tensor_Prob -act ${TractPath}/${ID}_5tt_coreg.mif -seed_random_per_voxel ${TractPath}/${ID}_5tt_coreg_wm_binary.mif 100 ${DTIpath}/${ID}_DWI_QCd_fixed.mif ${TractPath}/${ID}_WMbinarymask.tck${normal}"
#tckgen -algorithm Tensor_Prob -act ${TractPath}/${ID}_5tt_coreg.mif -seed_random_per_voxel ${TractPath}/${ID}_5tt_coreg_wm_binary.mif 100 ${DTIpath}/${ID}_DWI_QCd_fixed.mif ${TractPath}/${ID}_WMbinarymask.tck
# outputs ID.tck (the full tracks!)

echo -e "${Cyan}================================================================="
echo " Creation of subsample (for viewing purposes) ${ID} ..."
echo -e "=================================================================${NC}"
echo "${bold}tckedit ${TractPath}/${ID}_gmwmi.tck -number 500k ${TractPath}/${ID}_500k_gmwmi.tck${normal}"
tckedit ${TractPath}/${ID}_gmwmi.tck -number 500k ${TractPath}/${ID}_500k_gmwmi.tck
# wm image
#echo "${bold}tckedit ${TractPath}/${ID}_WMbinarymask.tck -number 20k ${TractPath}/${ID}_20k_WMbinarymask.tck${normal}"
#tckedit ${TractPath}/${ID}_WMbinarymask.tck -number 20k ${TractPath}/${ID}_20k_WMbinarymask.tck
# outputs ${ID}_20k_gmwmi.tck and ${ID}_20k_WMbinarymask.tck

echo -e "${Cyan}================================================================="
echo " Convert .tck to .trk for 3D visualization ${ID} ..."
echo -e "=================================================================${NC}"
# e2 can't run the script because doesn't have nibabel, so for e2 this will be commented!
# It works with .nii.gz not .mif
# gmwmi
echo "${bold}tck2trk.py ${TractPath}/${ID}_500k_gmwmi.tck ${DTIpath}/${ID}_DWI_QCd_fixed.nii.gz ${TractPath}/${ID}_500k_gmwmi.trk${normal}"
tck2trk.py ${TractPath}/${ID}_500k_gmwmi.tck ${DTIpath}/${ID}_DWI_QCd_fixed.nii.gz ${TractPath}/${ID}_500k_gmwmi.trk
# wm image
#echo "${bold}tck2trk.py ${TractPath}/${ID}_20k_WMbinarymask.tck ${DTIpath}/${ID}_DWI_QCd_fixed.nii.gz ${TractPath}/${ID}_20k_WMbinarymask.trk${normal}"
#tck2trk.py ${TractPath}/${ID}_20k_WMbinarymask.tck ${DTIpath}/${ID}_DWI_QCd_fixed.nii.gz ${TractPath}/${ID}_20k_WMbinarymask.trk
echo ""

echo ""

echo -e "${Cyan}==================================================================="
echo "dti_tractography.sh completed."
echo " "
echo ">>>> QC check point"
echo " "
echo "OUTPUT (in (Tractography)):"
echo "${ID}_maskT1.mif 				- The post T1w mask"
echo "${ID}_5tt.mif 				- The 5tt based on T1w mask"
echo "${ID}_dwi2t1_fsl.mat 			- The transform in fsl format"
echo "${ID}_dwi2t1_mrtrix.txt 			- The transform in mrtrix format"
echo "${ID}_maskT1_coreg.mif 			- The post T1w mask coregistered with DWI"
echo "${ID}_5tt_coreg.mif 			- The 5tt based on T1w mask coregistered with DWI"
echo "${ID}_gmwmSeed.mif 			- The seed to start the streamlines"
echo "${ID}_gmwmi.tck				- The full tracks"
echo "${ID}_500k_gmwmi.tck			- A sample to visualize in 2D the tracks in mrview"
echo "${ID}_500k_gmwmi.trk			- A sample to visualize in 3D the tracks in Trackvis"
#echo "With white matter:"
#echo "${ID}_5tt_coreg_wm.mif/.nii.gz		- White matter mask taken from the 5tt"
#echo "${ID}_5tt_coreg_wm_binary.mif/.nii.gz	- Binarize white matter mask taken from the 5tt"
#echo "${ID}_WMbinarymask.tck				- The full tracks"
#echo "${ID}_500k_WMbinarymask.tck		- A sample to visualize in 2D the tracks in mrview"
#echo "${ID}_500k_WMbinarymask.trk		- A sample to visualize in 3D the tracks in Trackvis"
echo -e "${NC}"


cd ${currPath}
# Now pause and QC check output!
 ) 2>&1 | tee $subjectsPath/out_logs/${ID}_dti_tractography.out
