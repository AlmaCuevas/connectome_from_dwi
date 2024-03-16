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
	echo "DESCRIPTION"
	echo "	- Relabelling atlas to match connectome row order"
	echo " 	(The chosen atlas is Desikan, from the Freesurfer)"
	echo "	- Compute connectome"
	echo " "
	echo "PREREQUISITE:"
	echo "  	- dti_maskT1_WMmask.sh has been called on subject data."
	echo "	- Expects folder structure and naming convention from Tractography function."
	echo "	"
	echo "USAGE:"
	echo "	"
	echo "	connectome.sh < %s subjs_folder > < %s ID >"
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
	connectome.sh
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
transformPath=${subjPath}/Diffusion/Preproc_files/Transforms
DTIpath=${subjPath}/Diffusion/DTI_corrected
TractPath=${subjPath}/Diffusion/Tractography
lut=/root_folder/here/FreeSurferColorLUT.txt
ConnectomePath=${subjPath}/Diffusion/Connectome
mrtrix_fsfile=/root_folder/here/fs_default.txt
mkdir -p ${ConnectomePath}

mkdir -p $subjectsPath/out_logs # Save in out_logs
( # Everything would be save from now on

if [ ! -d $subjPath ]; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: $subjPath does not exist. Cannot continue.${NC}"
	connectome.sh
	exit 1
elif [ ! -d $DTIpath ]; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: $DTIpath does not exist. Cannot continue.${NC}"
	connectome.sh
	exit 1
fi

echo "======================================================================================================"
echo "Preparing Desikan atlas for MRtrix, relabelling atlas to match connectome row order for ${ID}..."
echo "======================================================================================================"
# https://mrtrix.readthedocs.io/en/latest/quantitative_structural_connectivity/ismrm_hcp_tutorial.html

# Modify the integer values in the parcellated image, such that the numbers in the image no longer 
# correspond to entries in FreeSurfer’s colour lookup table, but rows and columns of the connectome.
# Needs FS file FreeSurferColorLUT.txt
# Needs MRtrix file fs_default.txt

# ${ID}_nodes.mif is converted/relabelled aparc+aseg
# All structures of interest have a unique integer value between 1 and N, where N is the number of nodes
echo "${bold}labelconvert ${freesurferPath}/mri/aparc+aseg.mgz ${lut} ${mrtrix_fsfile} ${ConnectomePath}/${ID}_nodes.mif${normal}"
labelconvert ${freesurferPath}/mri/aparc+aseg.mgz ${lut} ${mrtrix_fsfile} ${ConnectomePath}/${ID}_nodes.mif

# Replace FreeSurfer’s estimates of sub-cortical grey matter structures with estimates from FSL’s FIRST tool
echo "${bold}labelsgmfix ${ConnectomePath}/${ID}_nodes.mif ${diffPath}/${ID}_T1W2b0.nii.gz ${mrtrix_fsfile} ${ConnectomePath}/${ID}_nodes_fixSGM.mif -premasked${normal}"
labelsgmfix ${ConnectomePath}/${ID}_nodes.mif ${diffPath}/${ID}_T1W2b0.nii.gz ${mrtrix_fsfile} ${ConnectomePath}/${ID}_nodes_fixSGM.mif -premasked
#Output: ${ID}_nodes.mif and ${ID}_nodes_fixSGM.mif

echo -e "${Cyan}================================================================="
echo "Compute connectome for ${ID} ..."
echo -e "=================================================================${NC}"
#-symmetric Make matrices symmetric on output
#-zero_diagonal Set matrix diagonal to zero on output
#-scale_invnodevol scale each contribution to the connectome edge by the inverse of the two node volumes
#-out_assignments path output the node assignments of each streamline to a file; this can be used subsequently e.g. by the command connectome2tck

echo "Sum Streamline"
echo "${bold}tck2connectome -symmetric -zero_diagonal ${TractPath}/${ID}_gmwmi.tck ${ConnectomePath}/${ID}_nodes_fixSGM.mif ${ConnectomePath}/${ID}_sum_streamline_connectome.csv -out_assignments ${ConnectomePath}/${ID}_assignments.txt -force${normal}"
tck2connectome -symmetric -zero_diagonal ${TractPath}/${ID}_gmwmi.tck ${ConnectomePath}/${ID}_nodes_fixSGM.mif ${ConnectomePath}/${ID}_sum_streamline_connectome.csv -out_assignments ${ConnectomePath}/${ID}_sum_streamline_assignments.txt -force
# ${ID}_assignments.txt and ${ID}_sum_streamline_connectome.csv

echo "Mean Streamline"
echo "${bold}tck2connectome -symmetric -zero_diagonal ${TractPath}/${ID}_gmwmi.tck ${ConnectomePath}/${ID}_nodes_fixSGM.mif ${ConnectomePath}/${ID}_sum_streamline_connectome.csv -out_assignments ${ConnectomePath}/${ID}_assignments.txt -force${normal}"
tck2connectome -symmetric -zero_diagonal ${TractPath}/${ID}_gmwmi.tck ${ConnectomePath}/${ID}_nodes_fixSGM.mif ${ConnectomePath}/${ID}_mean_streamline_connectome.csv -stat_edge mean -out_assignments ${ConnectomePath}/${ID}_mean_streamline_assignments.txt -force
# ${ID}_mean_assignments.txt and ${ID}_mean_streamline_connectome.csv

echo ""
echo "FA" # Using the pre FA connectome
echo "${bold}tcksample ${TractPath}/${ID}_gmwmi.tck ${DTIpath}/${ID}_fa_fixed.mif ${ConnectomePath}/${ID}_mean_FA_per_streamline.csv -stat_tck mean -force${normal}"
tcksample ${TractPath}/${ID}_gmwmi.tck ${DTIpath}/${ID}_fa_fixed.mif ${ConnectomePath}/${ID}_mean_FA_per_streamline.csv -stat_tck mean -force

echo "${bold}tck2connectome ${TractPath}/${ID}_gmwmi.tck ${ConnectomePath}/${ID}_nodes_fixSGM.mif ${ConnectomePath}/${ID}_mean_FA_connectome.csv -scale_file ${ConnectomePath}/${ID}_mean_FA_per_streamline.csv -stat_edge mean -force${normal}"
tck2connectome ${TractPath}/${ID}_gmwmi.tck ${ConnectomePath}/${ID}_nodes_fixSGM.mif ${ConnectomePath}/${ID}_mean_FA_connectome.csv -scale_file ${ConnectomePath}/${ID}_mean_FA_per_streamline.csv -stat_edge mean -force

echo -e "${Cyan}==================================================================="
echo "connectome.sh completed."
echo " "
echo ">>>> QC check point:"
echo " "
echo "OUTPUT (in (Connectome)):"
echo "${ID}_nodes.mif		- Parcellation image"
echo "${ID}_nodes_fixSGM.mif	- Parcellation image"
echo "${ID}_sum_assignments.txt	- Node assignments of each streamline"
echo "${ID}_sum_connectome.csv	- File containing edge weights"
echo "${ID}_mean_assignments.txt	- Node assignments of each streamline"
echo "${ID}_mean_connectome.csv	- File containing edge weights"
echo "${ID}_mean_FA_per_streamline.csv"
echo "${ID}_mean_FA_connectome.csv"
echo ""
echo -e "${NC}"


cd ${currPath}
# Now pause and QC check output!
 ) 2>&1 | tee $subjectsPath/out_logs/${ID}_Connectome.out




