#!/bin/bash

#__author__ = 'AC'
#__contact__ = 'XXXX'
#__date__ = '10/2021'
#__version__ = '0.1'

# This are the following steps for diffusion done with the *dwifslpreproc* function form MRtrix3

# Color codes
RED='\033[0;31m'
Cyan='\033[1;36m'
NC='\033[0m' # No Color

if [ $# -eq 0 ] ; then
	echo " "
	echo " "
	echo "Author: AC"
	echo " "
	echo " "
	echo " "
	echo "DESCRIPTION:"
	echo "	- Performs an skull strip with the first b0 volume."
	echo "	- Apply a brain mask to the rest of the DWI volume."
	echo "	- Calling dwifslpreproc and patient motion correction"
	echo "	- Correct DWI volume for B1 inhomogeneity with params [initial mesh resolution in mm, spline order] as [100,3]"
	echo " "
	echo "PREREQUISITE:"
	echo "  	- qc_freesurfer.sh has been called on subject data."
	echo "	- dMRI_pipeline_prep_files.sh called on subject data."
	echo "- Expects folder structure and naming convention from dMRI pipeline."
	echo "	"
	echo "USAGE:"
	echo "	"
	echo "	dMRI_pipeline_dwifsl.sh < %s ID > < %s subjects_folder > < [optional] flag_FSL: 0 (default) || 1 >"
	echo " "
	echo "	%s ID		      		: Subject ID that prepends all output"
	echo "	%s subjects_folder		: Root subjects folder where the ID and DICOM RAW files can be found"
	echo "	[%d flag_FSL]        	: Processing option, [0 || 1]"
	echo "						0 = Not show skull-stripping and unbiased DWI volumes"
        echo "		                           	1 = Open FSLeyes of the skull-stripping (${ID}_brain.nii.gz) and unbiased (${ID}_unbiased.nii.gz) DWI volumes"

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
	echo -e "${RED}ERROR ::: $# arguments entered to call dMRI_pipeline_dwifsl.sh when expecting 2 or 3.${NC}"
	dMRI_pipeline_dwifsl.sh
	exit 1
fi

currPath=`pwd`

ID=$1
subjectsPath=$2
flag_FSL=${3:-0}

subjPath=${subjectsPath}/${ID}
diffPath=${subjPath}/Diffusion/Preproc_files
preEddyPath=${diffPath}/PreEddy
eddyPath=${diffPath}/Eddy
mkdir -p $eddyPath

mkdir -p $subjectsPath/out_logs # Save in out_logs
( # Everything would be save from now on

if [ ! -d $subjDir ]; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: $subjDir does not exist. Cannot continue.${NC}"
	dMRI_pipeline_dwifsl.sh
	exit 1
fi
if [ ! -d $preEddyPath ]; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: $preEddyPath does not exist. Cannot continue.${NC}"
	echo -e "		Have you called dMRI_pipeline_prep_files.sh?${NC}"
	dMRI_pipeline_dwifsl.sh
	exit 1
fi

cd ${diffPath}


echo -e "${Cyan}================================================================="
echo " Skull strip ${ID} ...."
echo -e "=================================================================${NC}"

echo "fslroi ${preEddyPath}/${ID}_DWI_denoised.nii.gz /${ID}_b0_brain.nii.gz 0 1"
fslroi ${preEddyPath}/${ID}_DWI_denoised.nii.gz ${eddyPath}/${ID}_b0_brain.nii.gz 0 1
# Output: ${ID}_b0_brain.nii.gz which is only the first 0 volume with the whole skull

echo -e "${Cyan}================================================================="
echo " Creation of the brain mask ${ID} ...."
echo -e "=================================================================${NC}"
# https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/BET/UserGuide
# Brain Extraction Tool deletes non-brain tissue from an image of the whole head.
# -m generate binary brain mask 
# -f <f> fractional intensity threshold (0->1); default=0.5; smaller values give larger brain outline estimates
echo " "
echo "bet ${eddyPath}/${ID}_b0_brain.nii.gz ${eddyPath}/${ID}_b0_preEddy_brain  -m -f 0.2"
bet ${eddyPath}/${ID}_b0_brain.nii.gz ${eddyPath}/${ID}_b0_preEddy_brain  -m -f 0.2
# Output: ${ID}_b0_preEddy_brain_mask.nii.gz, which is only the silhouette brain

echo -e "${Cyan}================================================================="
echo " Apply brain mask to the rest of the DWI volume ${ID} ...."
echo -e "=================================================================${NC}"

# -Tmean   : Dimensionality reduction operation of mean across time
echo "fslmaths ${preEddyPath}/${ID}_DWI_denoised.nii.gz -mul ${eddyPath}/${ID}_b0_preEddy_brain_mask ${eddyPath}/${ID}_brain.nii.gz"
fslmaths ${preEddyPath}/${ID}_DWI_denoised.nii.gz -mul ${eddyPath}/${ID}_b0_preEddy_brain_mask ${eddyPath}/${ID}_brain.nii.gz
# Output: ${ID}_brain.nii.gz is the complete DWI package with the skull stripped.

echo -e "${Cyan}================================================================="
echo " Convert .nii.gz to .mif ${ID} ...."
echo -e "=================================================================${NC}"
# MRtrix uses .mif so we will temporary converting the data in another format .mif
echo "mrconvert ${eddyPath}/${ID}_brain.nii.gz ${eddyPath}/${ID}_brain.mif -fslgrad ${preEddyPath}/${ID}_diffusion.bvec ${preEddyPath}/${ID}_diffusion.bval"
mrconvert ${eddyPath}/${ID}_brain.nii.gz ${eddyPath}/${ID}_brain.mif -fslgrad ${preEddyPath}/${ID}_diffusion.bvec ${preEddyPath}/${ID}_diffusion.bval
# Output: ${ID}_brain.mif

echo -e "${Cyan}================================================================="
echo " Calling Eddy for eddy current and patient motion correction on ${ID} ...."
echo -e "=================================================================${NC}"

echo ""
dwifslpreproc ${eddyPath}/${ID}_brain.mif ${eddyPath}/${ID}_eddy.mif -rpe_none -pe_dir j- -fslgrad ${preEddyPath}/${ID}_diffusion.bvec ${preEddyPath}/${ID}_diffusion.bval -eddy_options " --slm=linear" -export_grad_fsl ${eddyPath}/${ID}_eddy.bvec ${eddyPath}/${ID}_eddy.bval -eddyqc_all ${eddyPath}
# -eddyqc_text ${eddyPath} for just text, the -eddyqc_all ${eddyPath} is for quad too
# Output: ${ID}_eddy.mif and the b gradient files ${ID}_eddy.bvec and ${ID}_eddy.bval; qc folder

echo -e "${Cyan}================================================================="
echo " Correct DWI volume for B1 inhomogeniety ${ID} ...."
echo -e "=================================================================${NC}"
# Perform B1 field inhomogeneity correction for a DWI volume series
# To remove low frequency intensity nonuniformity present in the image data also known as bias, inhomogeneity, illumination nonuniformity, or gain field
# Perform DWI bias field correction using the N4 algorithm as provided in ANTs
# -bias image Output the estimated bias field
# -ants.b [100,3] N4BiasFieldCorrection option -b. [initial mesh resolution in mm, spline order] This value is optimised for human adult data and needs to be adjusted for rodent data.
echo "dwibiascorrect ants ${eddyPath}/${ID}_eddy.mif ${eddyPath}/${ID}_unbiased.mif -bias ${eddyPath}/${ID}_bias.mif -ants.b [100,3]"
dwibiascorrect ants ${eddyPath}/${ID}_eddy.mif ${eddyPath}/${ID}_unbiased.mif -bias ${eddyPath}/${ID}_bias.mif -ants.b [100,3]
# Output: The bias field ${ID}_bias.mif and the ${ID}_unbiased.mif result


echo -e "${Cyan}================================================================="
echo " Convert back from .mif to .nii.gz ${ID} ...."
echo -e "=================================================================${NC}"
# Undo the conversion since most programms prefer .nii.gz
echo "mrconvert ${eddyPath}/${ID}_unbiased.mif ${eddyPath}/${ID}_unbiased.nii.gz -fslgrad ${eddyPath}/${ID}_eddy.bvec ${eddyPath}/${ID}_eddy.bval"
mrconvert ${eddyPath}/${ID}_unbiased.mif ${eddyPath}/${ID}_unbiased.nii.gz -fslgrad ${eddyPath}/${ID}_eddy.bvec ${eddyPath}/${ID}_eddy.bval

echo "mrconvert ${eddyPath}/${ID}_eddy.mif ${eddyPath}/${ID}_eddy.nii.gz -force"
mrconvert ${eddyPath}/${ID}_eddy.mif ${eddyPath}/${ID}_eddy.nii.gz -force
# Output: ${ID}_eddy.nii.gz


if [ $flag_FSL != 0 ]; then
	echo -e "${Cyan}================================================================="
	echo " Check skull-stripping (${ID}_brain.nii.gz) and unbiased (${ID}_unbiased.nii.gz) DWI volumes in FSLeyes ${ID} ...."
	echo -e "=================================================================${NC}"
	cd ${eddyPath}
	echo "fsleyes ${ID}_brain.nii.gz -dr 0 300 ${ID}_unbiased.nii.gz -dr 0 300 &"
	fsleyes ${ID}_brain.nii.gz -dr 0 300 ${ID}_unbiased.nii.gz -dr 0 300 &
	echo " "
	exit 1
fi

echo -e "${Cyan}==================================================================="
echo "dMRI_pipeline_dwifsl.sh completed."
echo " "
echo ">>>> QC check point:"
echo "		Check ${ID}_eddy_correct.nii.gz,"
echo "		B1 corrected output ${ID}_unbiased.mif output, and ${ID}_brain_mask.mif"
echo " "
echo "OUTPUT (in (${subjPath}/Diffusion/Preproc_files/):"
echo "Eddy					- Folder created"
echo "Eddy/${ID}_b0_brain.nii.gz		- (Topup i/p, concatenated RAW AP/PA vols)"
echo "Eddy/${ID}_b0_preEddy_brain_mask.nii.gz	- (FSL o/p, final brain mask)"
echo "Eddy/${ID}_bias.mif			- (ANTs N4Bias o/p, post-eddy, bias field)"
echo "Eddy/${ID}_brain.mif/.nii.gz		- (FSL o/p, brain skull stripped DWI)"
echo "Eddy/${ID}_eddy.bval/.bvec		- (Eddy o/p, b gradient values from the dwifslpreproc function)"
echo "Eddy/${ID}_eddy.mif			- (Eddy o/p, dwifsl corrected DWI volume)"
echo "Eddy/${ID}_unbiased.mif/.nii.gz		- (ANTs N4Bias o/p, post-eddy, bias-corrected DWI)"
echo " "
echo "QC EDDY OUTPUTS:"
echo "*Eddy/eddy_mask.nii"
echo "*Eddy/eddy_movement_rms"
echo "*Eddy/eddy_outlier_map"
echo "*Eddy/eddy_outlier_n_sqr_stdev_map"
echo "*Eddy/eddy_outlier_n_stdev_map"
echo "*Eddy/eddy_outlier_report"
echo "*Eddy/eddy_parameters"
echo "*Eddy/eddy_post_eddy_shell_alignment_parameters"
echo "*Eddy/eddy_post_eddy_shell_PE_translation_parameters"
echo "*Eddy/eddy_restricted_movement_rms"
echo "*Eddy/quad/avg_b0.png"
echo "*Eddy/quad/avg_b1000.png"
echo "*Eddy/quad/qc.json"
echo "*Eddy/quad/qc.pdf"
echo "*Eddy/quad/ref_list.png"
echo -e "*Eddy/quad/ref.txt${NC}"

cd ${currPath}
# Now pause and QC check output!
 ) 2>&1 | tee $subjectsPath/out_logs/${ID}_dwifsl.out



