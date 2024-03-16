#!/bin/bash

# Bold
bold=$(tput bold)
normal=$(tput sgr0)

if [ $# -eq 0 ] ; then
	echo " "
	echo " "
	echo "Author: AC"
	echo " "
	echo "	Run a loop of code"
	echo " "
	echo "	run_loop_function.sh < %s subjects_folder >"
	echo " "
	echo "	%s subjects_folder	: Root folder where all the subjects folders (and names) are"
	echo "					This code will only detect if the name contains numbers, underscore and a 'pre' or 'post'"
	echo " "
	exit 1
fi

if [ $# -ne 1 ]; then
	echo "ERROR :::: $# arguments entered to call script_loop.sh when expecting 1"
	run_loop_function.sh
	exit 1
fi

subject_dir=${1:-/root_folder/here/}

subject_list=$(find ${subject_dir} -maxdepth 1 -mindepth 1 -type d -regex ".*[0-9]+[_]+[p]+[r]*[e]*[o]*[s]*[t]*" -exec basename {} \;) #regex pattern matches anything with numbes, underscore and the letters preost (to form pre or post)

echo " "
echo "${bold}The following subjects were found:${normal}"
printf "%s\n" ${subject_list}

cd ${subject_dir}

echo " "
echo "${bold}Running the following scripts:${normal}"

for ID in ${subject_list} ; do
	subjPath=$subject_dir/${ID}
	
	DTIpath=${subjPath}/Diffusion/DTI_corrected
	sparedPath=${subjPath}/Diffusion/spared_post
	
	cd ${sparedPath}
	
	echo "${bold}tckedit ${sparedPath}/${ID}_gmwmi.tck -number 500k ${sparedPath}/${ID}_500k_spared_post.tck${normal}"
	tckedit ${sparedPath}/${ID}_gmwmi.tck -number 500k ${sparedPath}/${ID}_500k_spared_post.tck
	
	echo "${bold}tck2trk.py ${sparedPath}/${ID}_500k_spared_post.tck ${PREDTIpath}/${numID}_pre_DWI_QCd_fixed.nii.gz ${sparedPath}/${ID}_500k_spared_post.trk${normal}"
	tck2trk.py ${sparedPath}/${ID}_500k_spared_post.tck ${PREDTIpath}/${numID}_pre_DWI_QCd_fixed.nii.gz ${sparedPath}/${ID}_500k_spared_post.trk
	
	echo "${bold}tck2trk.py ${sparedPath}/${ID}_500k_spared_post_inverse.tck ${DTIpath}/${ID}_DWI_QCd_fixed.nii.gz ${sparedPath}/${ID}_500k_spared_post_inverse.trk${normal}"
	tck2trk.py ${sparedPath}/${ID}_500k_spared_post_inverse.tck ${DTIpath}/${ID}_DWI_QCd_fixed.nii.gz ${sparedPath}/${ID}_500k_spared_post_inverse.trk
	echo ""
echo ""
done

echo " "
echo "${bold}Done! Have a nice day :D ${normal}"
