#!/bin/bash

#__author__ = 'AC'
#__contact__ = 'XXXX'
#__date__ = '10/2021'
#__version__ = '0.1'

# This are the following steps for diffusion

if [ $# -eq 0 ] ; then
	echo " "
	echo " "
	echo "Author: AC"
	echo " "
	echo " "
	echo " "
	echo "DESCRIPTION:"
	echo " 	*Eddy Correct version*"
	echo "	- Performs an skull strip with the first b0 volume."
	echo "	- Apply a brain mask to the rest of the DWI volume."
	echo "	- Co-register all volumes in DWI to the first b=0 volume"
	echo "	- Rotate acquisition b-vector file to match rotation in co-registration step"
	echo "	- Correct DWI volume for B1 inhomogeneity with params [initial mesh resolution in mm, spline order] as [100,3]"
	echo " "
	echo "PREREQUISITE:"
	echo "  	- qc_freesurfer.sh has been called on subject data."
	echo "	- dMRI_pipeline_prep_files.sh called on subject data."
	echo "	- Expects folder structure and naming convention from dMRI pipeline."
	echo "	"
	echo "USAGE:"
	echo "	"
	echo "	dMRI_pipeline.sh < %s ID > < %s subjs_folder > [flag_FSL: 0 (default) || 1 ]"
	echo " "
	echo "	%s ID		      		: Subject ID that prepends all output"
	echo "	%s subjs_folder		: Root subjects folder"
	echo "	[%d flag_FSL]        		: Processing option, [0 || 1]"
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
	echo "ERROR ::: $# arguments entered to call dMRI_pipeline_eddy_e2.sh when expecting 2 or 3."
	dMRI_pipeline.sh
	exit 1
fi

currPath=`pwd`

ID=$1
subjectsPath=$2
flag_FSL=$3

subjPath=${subjectsPath}/${ID}
diffPath=${subjPath}/Diffusion/Preproc_files
preEddyPath=${diffPath}/PreEddy
eddyPath=${diffPath}/Eddy_correct
mkdir $eddyPath

mkdir -p $subjectsPath/out_logs # Save in out_logs
( # Everything would be save from now on

if [ ! -d $subjDir ]; then
	echo " "
	echo " "
	echo "ERROR ::: $subjDir does not exist. Cannot continue."
	dMRI_pipeline.sh
	exit 1
fi
if [ ! -d $preEddyPath ]; then
	echo " "
	echo " "
	echo "ERROR ::: $preEddyPath does not exist. Cannot continue."
	echo "		Have you called dMRI_pipeline_prep_files.sh?"
	dMRI_pipeline.sh
	exit 1
fi

cd ${diffPath}


echo "================================================================="
echo " Skull strip ${ID} ...."
echo "================================================================="

echo "fslroi ${preEddyPath}/${ID}_DWI_denoised.nii.gz /${ID}_b0_brain.nii.gz 0 1"
fslroi ${preEddyPath}/${ID}_DWI_denoised.nii.gz ${eddyPath}/${ID}_b0_brain.nii.gz 0 1
# Output: ${ID}_b0_brain which is only the first 0 volume with the whole skull

echo "================================================================="
echo " Creation of the brain mask ${ID} ...."
echo "================================================================="
# https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/BET/UserGuide
# Brain Extraction Tool deletes non-brain tissue from an image of the whole head.
# -m generate binary brain mask 
# -f <f> fractional intensity threshold (0->1); default=0.5; smaller values give larger brain outline estimates
echo " "
echo "bet ${eddyPath}/${ID}_b0_brain.nii.gz ${eddyPath}/${ID}_b0_brain  -m -f 0.2"
bet ${eddyPath}/${ID}_b0_brain.nii.gz ${eddyPath}/${ID}_b0_brain  -m -f 0.2
# Output: ${ID}_b0_brain_mask, which is only the silhouette brain


echo "================================================================="
echo " Apply brain mask to the rest of the DWI volume ${ID} ...."
echo "================================================================="

# -Tmean   : Dimensionality reduction operation of mean across time
echo "fslmaths ${preEddyPath}/${ID}_DWI_denoised.nii.gz -mul ${eddyPath}/${ID}_b0_brain_mask ${eddyPath}/${ID}_brain.nii.gz"
fslmaths ${preEddyPath}/${ID}_DWI_denoised.nii.gz -mul ${eddyPath}/${ID}_b0_brain_mask ${eddyPath}/${ID}_brain.nii.gz
# Output: ${ID}_brain is the complete DWI package with the skull stripped.


echo "================================================================="
echo " Co-register all volumes in DWI to the first b = 0 volume ${ID} ...."
echo "================================================================="
# After running motion and eddy correction using FSLs eddy_correct tool, you can extract how much the data had to be moved to counter head motion using the .ecclog output. (http://www.diffusion-imaging.com/2015/11/a-guide-to-quantifying-head-motion-in.html)
# Set the volume number for the reference volume that will be used as a target to register all other volumes to. (default=0, i.e. the first volume)
echo "eddy_correct ${eddyPath}/${ID}_brain.nii.gz ${eddyPath}/${ID}_eddy_correct.nii.gz 0"
eddy_correct ${eddyPath}/${ID}_brain.nii.gz ${eddyPath}/${ID}_eddy_correct.nii.gz 0
# Output: Coregistered DWI volume (${ID}_eddy_correct.nii.gz), and a text file of b-vector rotations (${ID}_eddy_correct.ecclog)

echo "================================================================="
echo " Rotate acquisition b-vector file to match rotation in co-registration step ${ID} ...."
echo "================================================================="

# fdt_rotate_bvecs.sh from https://github.com/QTIM-Lab/qtim_tools/blob/master/qtim_tools/external/fdt_rotate_bvecs.sh
# Since eddy_current has a particular style this code was used instead of the one planned for the new eddy function (python3 rotate_bvecs_fsl.py3)
echo "fdt_rotate_bvecs.sh ${preEddyPath}/${ID}_diffusion.bvec ${eddyPath}/${ID}_rotated.bvec ${eddyPath}/${ID}_eddy_correct.ecclog"
fdt_rotate_bvecs.sh ${preEddyPath}/${ID}_diffusion.bvec ${eddyPath}/${ID}_rotated.bvec ${eddyPath}/${ID}_eddy_correct.ecclog
# Output: Rotated b-vector file – ${ID}_rotated.bvec

echo "================================================================="
echo " Convert .nii.gz to .mif ${ID} ...."
echo "================================================================="
# MRtrix uses .mif so we will temporary converting the data in another format .mif
echo "mrconvert ${eddyPath}/${ID}_eddy_correct.nii.gz ${eddyPath}/${ID}_eddy_correct.mif -fslgrad ${eddyPath}/${ID}_rotated.bvec ${preEddyPath}/${ID}_diffusion.bval"
mrconvert ${eddyPath}/${ID}_eddy_correct.nii.gz ${eddyPath}/${ID}_eddy_correct.mif -fslgrad ${eddyPath}/${ID}_rotated.bvec ${preEddyPath}/${ID}_diffusion.bval
# Output: ${ID}_eddy_correct.mif

echo "================================================================="
echo " Correct DWI volume for B1 inhomogeniety ${ID} ...."
echo "================================================================="
# Perform B1 field inhomogeneity correction for a DWI volume series
# To remove low frequency intensity nonuniformity present in the image data also known as bias, inhomogeneity, illumination nonuniformity, or gain field
# Perform DWI bias field correction using the N4 algorithm as provided in ANTs
# -bias image Output the estimated bias field
# -ants.b [100,3] N4BiasFieldCorrection option -b. [initial mesh resolution in mm, spline order] This value is optimised for human adult data and needs to be adjusted for rodent data.
echo "dwibiascorrect ants ${eddyPath}/${ID}_eddy_correct.mif ${eddyPath}/${ID}_unbiased.mif -bias ${eddyPath}/${ID}_bias.mif -ants.b [100,3]"
dwibiascorrect ants ${eddyPath}/${ID}_eddy_correct.mif ${eddyPath}/${ID}_unbiased.mif -bias ${eddyPath}/${ID}_bias.mif -ants.b [100,3]
# Output: The bias field ${ID}_bias.mif and the ${ID}_unbiased.mif result

echo "================================================================="
echo " Convert back from .mif to .nii.gz ${ID} ...."
echo "================================================================="
# Undo the conversion since most programms prefer .nii.gz
echo "mrconvert ${eddyPath}/${ID}_unbiased.mif ${eddyPath}/${ID}_unbiased.nii.gz -fslgrad ${eddyPath}/${ID}_rotated.bvec ${preEddyPath}/${ID}_diffusion.bval"
mrconvert ${eddyPath}/${ID}_unbiased.mif ${eddyPath}/${ID}_unbiased.nii.gz -fslgrad ${eddyPath}/${ID}_rotated.bvec ${preEddyPath}/${ID}_diffusion.bval
# Output: ${ID}_unbiased.nii.gz


if [ $flag_FSL != 0 ]; then
	echo "================================================================="
	echo " Check skull-stripping (${ID}_brain.nii.gz) and unbiased (${ID}_unbiased.nii.gz) DWI volumes in FSLeyes ${ID} ...."
	echo "================================================================="
	echo "fsleyes ${eddyPath}/${ID}_brain.nii.gz ${eddyPath}/${ID}_unbiased.nii.gz &"
	fsleyes ${eddyPath}/${ID}_brain.nii.gz ${eddyPath}/${ID}_unbiased.nii.gz &
	echo " "
	exit 1
fi

echo "==================================================================="
echo "dMRI_pipeline.sh completed."
echo " "
echo ">>>> QC check point:"
echo "		Check ${ID}_eddy_correct.nii.gz,"
echo "		B1 corrected output ${ID}_unbiased.mif output, and ${ID}_brain_mask.mif"
echo " "
echo "OUTPUT (in (${subjPath}/Diffusion/Preproc_files/):"
echo "Eddy_correct					- Folder created"
echo "Eddy_correct/${ID}_b0_brain.nii.gz		- (Topup i/p, concatenated RAW AP/PA vols)"
echo "Eddy_correct/${ID}_b0_brain_mask.nii.gz		- (FSL o/p, final brain mask)"
echo "Eddy_correct/${ID}_bias.mif			- (ANTs N4Bias o/p, post-eddy, bias field)"
echo "Eddy_correct/${ID}_brain.nii.gz			- (FSL o/p, brain skull stripped DWI)"
echo "Eddy_correct/${ID}_eddy_correct.ecclog		- (Eddy o/p, eddy corrected DWI head motion information)"
echo "Eddy_correct/${ID}_eddy_correct.mif/.nii.gz	- (Eddy o/p, eddy corrected DWI volume)"
echo "Eddy_correct/${ID}_rotated.bvec			- (Eddy o/p, rotated b-vectors post eddy correction)"
echo "Eddy_correct/${ID}_unbiased.mif/.nii.gz		- (ANTs N4Bias o/p, post-eddy, bias-corrected DWI)"

cd ${currPath}
# Now pause and QC check output!
 ) 2>&1 | tee $subjectsPath/out_logs/${ID}_eddycorrect.out





