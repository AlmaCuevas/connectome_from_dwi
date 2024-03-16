#!/bin/bash

#__author__ = 'AC'
#__contact__ = 'XXXX'
#__date__ = '10/2021'
#__version__ = '0.1'

# Color codes
RED='\033[0;31m'
Cyan='\033[1;36m'
NC='\033[0m' # No Color

if [ $# -eq 0 ] ; then
	echo " "
	echo "Creates Freeview QC script for each subject to quickly open them in Freeview"
	echo " "
	echo "- Expects folder structure and naming convention qc_freesurfer.sh."
	echo " "
	echo "USAGE:"
	echo " "
	echo "	openfs.sh < %s subjects_dir > < %s subject_ID > < %d Optioning option >"
	echo ""
	echo "	%s subjects_dir    : Directory where subjects are located"
	echo "  	%d Opening-option  : 0 - Freesurfer"
	echo "			     1 - DWI"
	echo "			     2 - FA and DT"
	echo "			     3 - Co-registration of average dwi b0's and T1W"
	echo "			     4 - DWI with overlay of 5tt (Five Tissue Type) and wm/gm seed"
	echo "			     5 - Tractography in mrview"
	echo "			     6 - Tractography in Trackvis"
	echo "			     7 - Co-registration of pre and post T1 (for ID use only the number)"
	echo "			     8 - Manual edition of binary mask for resection"
	echo "			     9 - Spared Network tractography in mrview and trackvis"
	echo "	%s subject_ID      : ID from the subject to visualize"
	echo " "
	echo " "
	exit 1
fi

if [ $# -ne 3 ]; then
	echo -e "${RED}ERROR :::: $# arguments entered when expecting 3${NC}"
	exit 1
fi

#create variables
subject_dir=${1:-/root_folder/here/}
option=$2
ID=$3

if [ $option -eq 0 ]; then
freesurfer_dir="${subject_dir}/${ID}/Freesurfer"

echo -e "${Cyan} ${ID} ${NC}"
echo "freeview -v ${freesurfer_dir}/mri/brainmask.mgz ${freesurfer_dir}/mri/orig/001.mgz:visible=0 ${freesurfer_dir}/mri/aseg.mgz:colormap=lut:visible=0 ${freesurfer_dir}/mri/aparc+aseg.mgz:colormap=lut:visible=0 ${freesurfer_dir}/mri/wm.mgz:colormap=heat:opacity=0.4 ${freesurfer_dir}/mri/T1.mgz:visible=0 -f ${freesurfer_dir}/surf/lh.pial:edgecolor=red ${freesurfer_dir}/surf/rh.pial:edgecolor=red ${freesurfer_dir}/surf/lh.white:edgecolor=yellow ${freesurfer_dir}/surf/rh.white:edgecolor=yellow &"
echo " "
echo "cp -n ${freesurfer_dir}/mri/brainmask.mgz ${freesurfer_dir}/mri/brainmask_ORIG.mgz"
echo " "
echo "cp -n ${freesurfer_dir}/mri/wm.mgz ${freesurfer_dir}/mri/wm_ORIG.mgz"

freeview -v ${freesurfer_dir}/mri/brainmask.mgz ${freesurfer_dir}/mri/orig/001.mgz:visible=0 ${freesurfer_dir}/mri/aseg.mgz:colormap=lut:visible=0 ${freesurfer_dir}/mri/aparc+aseg.mgz:colormap=lut:visible=0 ${freesurfer_dir}/mri/wm.mgz:colormap=heat:opacity=0.4 ${freesurfer_dir}/mri/T1.mgz:visible=0 -f ${freesurfer_dir}/surf/lh.pial:edgecolor=red ${freesurfer_dir}/surf/rh.pial:edgecolor=red ${freesurfer_dir}/surf/lh.white:edgecolor=yellow ${freesurfer_dir}/surf/rh.white:edgecolor=yellow &
cp -n ${freesurfer_dir}/mri/brainmask.mgz ${freesurfer_dir}/mri/brainmask_ORIG.mgz
cp -n ${freesurfer_dir}/mri/wm.mgz ${freesurfer_dir}/mri/wm_ORIG.mgz



elif [ $option -eq 1 ]; then
eddyPath=${subject_dir}/${ID}/Diffusion/Preproc_files/Eddy
originalPath=${subject_dir}/COMPILED_RAW
cd ${eddyPath}
echo ""
echo "fsleyes ${ID}_RAW_DWI.nii.gz -dr 0 300 ${ID}_unbiased.nii.gz -dr 0 300 &"
fsleyes ${originalPath}/${ID}_RAW_DWI.nii.gz -dr 0 300 ${ID}_unbiased.nii.gz -dr 0 300 &



elif [ $option -eq 2 ]; then
DTIPath=${subject_dir}/${ID}/Diffusion/DTI_corrected
echo "mrview ${ID}_fa_fixed.mif -odf.load_tensor ${ID}_dt_fixed.mif &"
mrview ${DTIPath}/${ID}_fa_fixed.mif -odf.load_tensor ${DTIPath}/${ID}_dt_fixed.mif &



elif [ $option -eq 3 ]; then
diffPath=${subject_dir}/${ID}/Diffusion/Preproc_files
echo ""
echo "fsleyes ${diffPath}/${ID}_aveb0.nii.gz ${diffPath}/${ID}_T1W2b0.nii.gz &"
fsleyes ${diffPath}/${ID}_aveb0.nii.gz ${diffPath}/${ID}_T1W2b0.nii.gz &



elif [ $option -eq 4 ]; then
DTIPath=${subject_dir}/${ID}/Diffusion/DTI_corrected
TractPath=${subject_dir}/${ID}/Diffusion/Tractography
echo "Overlays of 5tt and gmwmi"
echo "mrview ${DTIPath}/${ID}_DWI_QCd_fixed.mif -overlay.load ${TractPath}/${ID}_5tt_coreg.mif -overlay.load ${TractPath}/${ID}_gmwmSeed.mif -overlay.colourmap 2 &"
mrview ${DTIPath}/${ID}_DWI_QCd_fixed.mif -overlay.load ${TractPath}/${ID}_5tt_coreg.mif -overlay.load ${TractPath}/${ID}_gmwmSeed.mif -overlay.colourmap 2 &



elif [ $option -eq 5 ]; then
DTIPath=${subject_dir}/${ID}/Diffusion/DTI_corrected
TractPath=${subject_dir}/${ID}/Diffusion/Tractography
echo "Tractography: Reduced tracts in mrview"
echo "mrview ${DTIPath}/${ID}_DWI_QCd_fixed.mif -tractography.load ${TractPath}/${ID}_20k_gmwmi.tck &"
mrview ${DTIPath}/${ID}_DWI_QCd_fixed.mif -tractography.load ${TractPath}/${ID}_20k_gmwmi.tck &



elif [ $option -eq 6 ]; then
TractPath=${subject_dir}/${ID}/Diffusion/Tractography
cd ${TractPath}
echo "Tractography: Reduced tracts in Trackvis"
echo "trackvis ${ID}_20k_gmwmi.trk &"
trackvis ${ID}_20k_gmwmi.trk &



elif [ $option -eq 7 ]; then
PRETractPath=${subject_dir}/${ID}_pre/Diffusion/Tractography
TransformsPath=${subject_dir}/${ID}_post/Diffusion/Transforms
PREdiffPath=$subject_dir/${ID}_pre/Diffusion/Preproc_files
PREfreesurferPath=$subject_dir/${ID}_pre/Freesurfer
PREDTIPath=${subject_dir}/${ID}_pre/Diffusion/DTI_corrected
echo "Co-registration of post to pre T1w"
echo "freeview ${PREfreesurferPath}/mri/brain.nii.gz ${PREDTIPath}/${ID}_pre_DWI_QCd_fixed.nii.gz ${TransformsPath}/1Warp.nii.gz &"
freeview ${PREfreesurferPath}/mri/brain.nii.gz ${PREDTIPath}/${ID}_pre_DWI_QCd_fixed.nii.gz ${TransformsPath}/1Warp.nii.gz &



elif [ $option -eq 8 ]; then
sparedPath=${subject_dir}/${ID}_post/Diffusion/spared_post
OLDsparedPath=${subject_dir}/${ID}_post/Diffusion/Extra_not_used/spared_post_FLIRTv1
PREfreesurferPath=$subject_dir/${ID}_pre/Freesurfer
TransformprepostPath=${subject_dir}/${ID}_post/Diffusion/Transforms
echo -e "${Cyan}		${ID}		${NC}"

echo "freeview -v ${sparedPath}/${ID}_post_maskT1_coreg.nii.gz ${PREfreesurferPath}/mri/brainmask.mgz:opacity=0.72 ${sparedPath}/${ID}_post_resection_binarymask_manual_generous.nii.gz:colormap=heat:opacity=0.6 &"
#freeview -v ${sparedPath}/${ID}_post_maskT1_coreg.nii.gz ${PREfreesurferPath}/mri/brainmask.mgz:opacity=0.72 ${sparedPath}/${ID}_post_resection_binarymask_manual_generous.nii.gz:colormap=heat:opacity=0.6 &
freeview -v ${sparedPath}/${ID}_post_maskT1_coreg.nii.gz ${OLDsparedPath}/${ID}_post_maskT1_coreg.nii.gz


elif [ $option -eq 9 ]; then
sparedPath=${subject_dir}/${ID}_post/Diffusion/spared_post
PREDTIPath=${subject_dir}/${ID}_pre/Diffusion/DTI_corrected
echo "Tractography view of spared network in mrview and tracvis"
echo "mrview ${PREDTIPath}/${ID}_pre_DWI_QCd_fixed.mif -overlay.load ${sparedPath}/${ID}_post_resection_binarymask_manual_generous.nii.gz -tractography.load ${sparedPath}/${ID}_post_500k_spared_post.tck &"
mrview ${PREDTIPath}/${ID}_pre_DWI_QCd_fixed.mif -overlay.load ${sparedPath}/${ID}_post_resection_binarymask_manual_generous.nii.gz -tractography.load ${sparedPath}/${ID}_post_500k_spared_post.tck &

#mrview ${PREDTIPath}/${ID}_pre_DWI_QCd_fixed.mif -overlay.load ${sparedPath}/${ID}_post_resection_binarymask_manual_generous.nii.gz -tractography.load ${sparedPath}/${ID}_post_spared_post_inverse.tck &
#echo "trackvis ${sparedPath}/${ID}_post_20k_spared_post.trk &"
#trackvis ${sparedPath}/${ID}_post_20k_spared_post.trk &



else
echo " "
echo " "
echo -e "${RED}Please choose which sequence you want to see${NC}"
open_files.sh 
exit 1
fi

