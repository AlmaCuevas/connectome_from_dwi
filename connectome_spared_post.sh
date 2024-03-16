#!/bin/bash

#__author__ = 'AC'
#__contact__ = 'XXXX'
#__date__ = '12/2021'
#__version__ = '0.1'


codeName=connectome_spared_post.sh

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
	echo "	- Exclude the streamlines within the resection mask"
	echo "	- Compute the surgically spared connectome"
	echo " "
	echo "PREREQUISITE:"
	echo "		- You need the cleaned mask in the same folder ${ID}_resection_binarymask_manual.mif "
	echo "  	- spared_post.sh structure and naming convention from Tractography function."
	echo "	"
	echo "USAGE:"
	echo "	"
	echo "	${codeName} < %s subjs_folder > ${bold}< %d ID without pre or post >${bold}"
	echo " "
	echo "	%s ID		      		: Subject number ID that prepends all output"
	echo "	%s subjs_folder		: Root subjects folder created after calling a qc prep"
	echo " "
	echo "  	*The out will be save in the subjs_folder/out_logs*"
	echo "	*Include full paths*"
	echo "	*Same folder as spared_post.sh*"
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

subjectsPath=${1:-/root_folder/here/}
numID=$2

ID=${numID}_post
subjPath=$subjectsPath/${ID}

diffPath=${subjPath}/Diffusion/Preproc_files
PREdiffPath=$subjectsPath/${numID}_pre/Diffusion/Preproc_files

freesurferPath=${subjPath}/Freesurfer
PREfreesurferPath=$subjectsPath/${numID}_pre/Freesurfer

PRETractPath=$subjectsPath/${numID}_pre/Diffusion/Tractography
PREConnectomePath=$subjectsPath/${numID}_pre/Diffusion/Connectome
PREDTIpath=$subjectsPath/${numID}_pre/Diffusion/DTI_corrected

lut=/root_folder/here/FreeSurferColorLUT.txt
mrtrix_fsfile=/root_folder/here/fs_default.txt

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

echo -e "${Cyan}================================================================="
echo " Transform post T1w coregistered to preT1w to pre DWI  ${ID} ..."
echo -e "=================================================================${NC}"
# Using the same transform matrix from when preT1w was coregistrated to DWI

echo "${bold}mrconvert ${sparedPath}/${ID}_resection_binarymask_manual_generous.nii.gz ${sparedPath}/${ID}_resection_binarymask_manual_generous.mif -force${normal}"
mrconvert ${sparedPath}/${ID}_resection_binarymask_manual_generous.nii.gz ${sparedPath}/${ID}_resection_binarymask_manual_generous.mif -force

echo "${bold}mrtransform ${sparedPath}/${ID}_resection_binarymask_manual_generous.mif -linear ${PRETractPath}/${numID}_pre_dwi2t1_mrtrix.txt -inverse ${sparedPath}/${ID}_resection_binarymask_manual_generous_coreg.mif -force${normal}"
mrtransform ${sparedPath}/${ID}_resection_binarymask_manual_generous.mif -linear ${PRETractPath}/${numID}_pre_dwi2t1_mrtrix.txt -inverse ${sparedPath}/${ID}_resection_binarymask_manual_generous_coreg.mif -force

echo -e "${Cyan}================================================================="
echo " Exclude the streamlines within the resection mask ${ID} ..."
echo -e "=================================================================${NC}"
#
echo "${bold}tckedit ${PRETractPath}/${numID}_pre_gmwmi.tck ${sparedPath}/${ID}_spared_post_inverse.tck -exclude ${sparedPath}/${ID}_resection_binarymask_manual_generous.mif -inverse -force${normal}"
tckedit ${PRETractPath}/${numID}_pre_gmwmi.tck ${sparedPath}/${ID}_spared_post_inverse.tck -exclude ${sparedPath}/${ID}_resection_binarymask_manual_generous_coreg.mif -inverse -force

echo "${bold}tckedit ${PRETractPath}/${numID}_pre_gmwmi.tck ${sparedPath}/${ID}_spared_post.tck -exclude ${sparedPath}/${ID}_resection_binarymask_manual_generous.mif -force${normal}"
tckedit ${PRETractPath}/${numID}_pre_gmwmi.tck ${sparedPath}/${ID}_spared_post.tck -exclude ${sparedPath}/${ID}_resection_binarymask_manual_generous_coreg.mif -force

# To visualize the change
echo "${bold}tckedit ${sparedPath}/${ID}_spared_post.tck -number 500k ${sparedPath}/${ID}_500k_spared_post.tck -force${normal}"
tckedit ${sparedPath}/${ID}_spared_post.tck -number 500k ${sparedPath}/${ID}_500k_spared_post.tck -force

cd ${sparedPath}

echo "${bold}tck2trk.py ${sparedPath}/${ID}_500k_spared_post.tck ${PREDTIpath}/${numID}_pre_DWI_QCd_fixed.nii.gz ${sparedPath}/${ID}_500k_spared_post.trk${normal}"
tck2trk.py ${sparedPath}/${ID}_500k_spared_post.tck ${PREDTIpath}/${numID}_pre_DWI_QCd_fixed.nii.gz ${sparedPath}/${ID}_500k_spared_post.trk

echo -e "${Cyan}================================================================="
echo " Compute the surgically spared connectome for ${ID} ..."
echo -e "=================================================================${NC}"
#-symmetric Make matrices symmetric on output
#-zero_diagonal Set matrix diagonal to zero on output
#-scale_invnodevol scale each contribution to the connectome edge by the inverse of the two node volumes
#-out_assignments path output the node assignments of each streamline to a file; this can be used subsequently e.g. by the command connectome2tck
echo "Streamline mean"
echo "${bold}tck2connectome -symmetric -zero_diagonal ${sparedPath}/${ID}_spared_post.tck ${PREConnectomePath}/${numID}_pre_nodes_fixSGM.mif ${sparedPath}/${ID}_mean_streamline_spared_connectome.csv -out_assignments ${sparedPath}/${ID}_mean_streamline_spared_assignments.txt -stat_edge mean -force${normal}"
tck2connectome -symmetric -zero_diagonal ${sparedPath}/${ID}_spared_post.tck ${PREConnectomePath}/${numID}_pre_nodes_fixSGM.mif ${sparedPath}/${ID}_mean_streamline_spared_connectome.csv -out_assignments ${sparedPath}/${ID}_mean_streamline_spared_assignments.txt -stat_edge mean -force
# ${ID}_mean_streamline_assignments.txt and ${ID}_mean_streamline_connectome.csv

echo "Streamline sum"
echo "${bold}tck2connectome -symmetric -zero_diagonal ${sparedPath}/${ID}_spared_post.tck ${PREConnectomePath}/${numID}_pre_nodes_fixSGM.mif ${sparedPath}/${ID}_sum_streamline_spared_connectome.csv -out_assignments ${sparedPath}/${ID}_sum_streamline_spared_assignments.txt -force${normal}"
tck2connectome -symmetric -zero_diagonal ${sparedPath}/${ID}_spared_post.tck ${PREConnectomePath}/${numID}_pre_nodes_fixSGM.mif ${sparedPath}/${ID}_sum_streamline_spared_connectome.csv -out_assignments ${sparedPath}/${ID}_sum_streamline_spared_assignments.txt -force
# ${ID}_sum_streamline_assignments.txt and ${ID}_sum_streamline_spared_connectome_.csv

echo ""
echo "FA mean" # Using the pre FA connectome
echo "${bold}tcksample ${sparedPath}/${ID}_spared_post.tck ${PREDTIpath}/${numID}_pre_fa_fixed.mif ${sparedPath}/${ID}_mean_FA_per_streamline.csv -stat_tck mean -force${normal}"
tcksample ${sparedPath}/${ID}_spared_post.tck ${PREDTIpath}/${numID}_pre_fa_fixed.mif ${sparedPath}/${ID}_mean_FA_per_streamline.csv -stat_tck mean -force

echo "${bold}tck2connectome -symmetric -zero_diagonal ${sparedPath}/${ID}_spared_post.tck ${PREConnectomePath}/${numID}_pre_nodes_fixSGM.mif ${sparedPath}/${ID}_mean_FA_connectome.csv -scale_file ${sparedPath}/${ID}_mean_FA_per_streamline.csv -stat_edge mean -force${normal}"
tck2connectome -symmetric -zero_diagonal ${sparedPath}/${ID}_spared_post.tck ${PREConnectomePath}/${numID}_pre_nodes_fixSGM.mif ${sparedPath}/${ID}_mean_FA_connectome.csv -scale_file ${sparedPath}/${ID}_mean_FA_per_streamline.csv -stat_edge mean -force

echo "${bold}${normal}"
echo -e "${Cyan}==================================================================="
echo "${codeName} completed."
echo " "
echo ">>>> QC check point:"
echo " "
echo "OUTPUT (in (${codeName})):"
echo "${ID}_sum_streamline_spared_assignments.txt		- Node assignments of (sum) streamlines"
echo "${ID}_sum_streamline_spared_connectome.csv		- Connectome matrix of (sum) streamlines"
echo "${ID}_mean_streamline_spared_assignments.txt		- Node assignments of (sum) streamlines"
echo "${ID}_mean_streamline_spared_connectome.csv		- Connectome matrix of (sum) streamlines"
echo "${ID}_mean_FA_per_streamline.csv				- "
echo "${ID}_mean_FA_connectome.csv				- "
echo "${ID}_spared_post.tck					- Tractography with the resection streamline exclusion"
echo "${ID}_500k_spared_post.tck				- Tractography with exclusion for visualization"
echo "${ID}_resection_binarymask_manual_generous.mif		- Conversion of the manual drawing to .mif"
echo "${ID}_resection_binarymask_manual_generous_coreg.mif	- Coregistration of the "
echo -e "${NC}"


cd ${currPath}
# Now pause and QC check output!
 ) 2>&1 | tee $subjectsPath/out_logs/${ID}_${codeName}.out




