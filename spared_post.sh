#!/bin/bash

#__author__ = 'AC'
#__contact__ = 'XXXX'
#__date__ = '12/2021'
#__version__ = '0.1'


codeName=spared_post_FLIRT.sh

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
	echo "DESCRIPTION"	
	echo "	- Co-register the post T1w to the pre T1w"
	echo "		The pre is the reference"
	echo " "
	echo "PREREQUISITE:"
	echo "  	- dti_tractography.sh has been called on the pre subject data."
	echo "	- Expects folder structure and naming convention from Tractography function."
	echo "	"
	echo "USAGE:"
	echo "	"
	echo "	${codeName} ${bold}< %d ID without pre or post >${bold} < %s subjs_folder >"
	echo " "
	echo "	%s ID		      		: Subject number ID that prepends all output"
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
	${codeName}
	exit 1
fi

currPath=`pwd`

subjectsPath=$1
numID=$2

ID=${numID}_post
subjPath=$subjectsPath/${ID}

freesurferPath=${subjPath}/Freesurfer
PREfreesurferPath=$subjectsPath/${numID}_pre/Freesurfer

sparedPath=${subjPath}/Diffusion/spared_post
mkdir -p ${sparedPath}

mkdir -p $subjectsPath/out_logs # Save in out_logs
( # Everything would be save from now on

if [ ! -d $subjPath ]; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: $subjPath does not exist. Cannot continue."
	echo " Remember to put only the NUMBER, not pre or post"
	echo " are you sure this subject has pre and post? ${NC}"
	${codeName}
	exit 1
elif [ ! -d $PRETractPath ]; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: $PRETractPath does not exist. Cannot continue."
	echo " are you sure this subject has pre and post? ${NC}"
	${codeName}
	exit 1
elif [ ! -d $freesurferPath ]; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: $freesurferPath does not exist. Cannot continue.${NC}"
	${codeName}
	exit 1
fi

echo "======================================================================================================"
echo " Calculate the resection mask ${ID}..."
echo "======================================================================================================"

# To have it handy for visualization purposes
echo "${bold}mrconvert ${freesurferPath}/mri/brain.nii.gz ${sparedPath}/${ID}_maskT1.mif${normal}"
mrconvert ${freesurferPath}/mri/brain.nii.gz ${sparedPath}/${ID}_maskT1.mif

echo "Co-registration, Transform matrix"
# flirt is the main program that performs affine registration. The main options are: an input (-in) and a reference (-ref) volume; the calculated affine transformation that registers the input to the reference which is saved as a 4x4 affine matrix (-omat); and output volume (-out) where the transform is applied to the input volume to align it with the reference volume. 
echo "${bold}flirt -in ${freesurferPath}/mri/brain.nii.gz -ref ${PREfreesurferPath}/mri/brain.nii.gz -dof 6 -omat ${sparedPath}/${ID}_postT1w2preT1w.mat -out ${sparedPath}/${ID}_maskT1_coreg.nii.gz ${normal}" # with pre b0's average mask
flirt -in ${freesurferPath}/mri/brain.nii.gz -ref ${PREfreesurferPath}/mri/brain.nii.gz -dof 6 -omat ${sparedPath}/${ID}_postT1w2preT1w.mat -out ${sparedPath}/${ID}_maskT1_coreg.nii.gz # post to pre

echo "${bold}${normal}"
echo -e "${Cyan}==================================================================="
echo "${codeName} completed."
echo " "
echo ">>>> QC check point:"
echo " 	- Create the binary mask from the resection"
echo " "
echo "OUTPUT (in (${codeName})):"
echo "${ID}_maskT1.mif			- Post Structural images"
echo "${ID}_maskT1_coreg.mif/.nii.gz	- Post Structural images co-registered to pre T1w"
echo -e "${NC}"


cd ${currPath}
# Now pause and QC check output!
 ) 2>&1 | tee $subjectsPath/out_logs/${ID}_${codeName}.out




