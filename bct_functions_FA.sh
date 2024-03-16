#!/bin/bash

#__author__ = 'AC'
#__contact__ = 'XXXX'
#__date__ = '01/2022'
#__version__ = '0.1'


codeName=bct_functions_FA.sh

# Bold
bold=$(tput bold)
normal=$(tput sgr0)

if [ $# -eq 0 ] ; then
	echo " "
	echo " "
	echo "Author: AC"
	echo " "
	echo "	Run a loop of code to compute the bct functions for pre and post connectomes"
	echo " "
	echo "	bct_functions_FA.sh < %s subjects_folder >"
	echo " "
	echo "	%s subjects_folder	: Root folder where all the subjects folders (and names) are"
	echo "					This code will only detect if the name contains numbers, underscore and a 'pre' or 'post'"
	echo " "
	exit 1
fi

if [ $# -ne 1 ]; then
	echo "ERROR :::: $# arguments entered to call script_loop.sh when expecting 1"
	bct_functions_FA.sh
	exit 1
fi

subject_dir=${1:-/root_folder/here/}

mkdir -p $subjectsPath/out_logs # Save in out_logs
( # Everything would be save from now on

subject_list='25_pre 95_pre 143_pre 0_pre 89_pre 154_pre 1_pre 4_pre 183_pre 9_pre 17_pre 20_pre 21_pre 23_pre 83_pre 107_pre 120_pre 126_pre 127_pre 128_pre 146_pre'

echo " "
echo "${bold}The following subjects were found:${normal}"
printf "%s\n" ${subject_list}

cd ${subject_dir}

echo " "
for ID in ${subject_list} ; do
	subjPath=$subject_dir/${ID}
	
	sparedPath=${subjPath}/Diffusion/Connectome
	
	pro_Path=${subjPath}/Diffusion/Full_Connectome_Outputs_FA
	mkdir -p ${pro_Path}
	
	
	# echo "${bold}bct_functions.py ${sparedPath}/${ID}_mean_FA_connectome.csv ${ID}_mean_FA ${pro_Path}${normal}"
	# bct_functions.py ${sparedPath}/${ID}_mean_FA_connectome.csv ${ID}_mean_FA ${pro_Path}
	
	echo "${bold}bct_functions_FA.py ${sparedPath}/${ID}_mean_FA_connectome.csv ${ID}_mean_FA_connectome ${pro_Path}${normal}"
	bct_functions_FA.py ${sparedPath}/${ID}_mean_FA_connectome.csv ${ID}_mean_FA_connectome ${pro_Path}
	
	echo ""
echo ""
done
echo "${bold}Look at you. Congratulations. All pre done! :D ${normal}"

subject_list='25_post 143_post 0_post 183_post 154_post 1_post 17_post 21_post 83_post 107_post 120_post 127_post 146_post'

echo " "
echo "${bold}The following subjects were found:${normal}"
printf "%s\n" ${subject_list}

cd ${subject_dir}

echo " "
echo "${bold}Running the following scripts:${normal}"

for ID in ${subject_list} ; do
	subjPath=$subject_dir/${ID}
	
	sparedPath=${subjPath}/Diffusion/spared_post
	
	pro_Path=${subjPath}/Diffusion/Full_Connectome_Outputs_FA
	mkdir -p ${pro_Path}
	
	echo "${bold}bct_functions_FA.py ${sparedPath}/${ID}_mean_FA_connectome.csv ${ID}_mean_FA_connectome ${pro_Path}${normal}"
	bct_functions_FA.py ${sparedPath}/${ID}_mean_FA_connectome.csv ${ID}_mean_FA_connectome ${pro_Path}
	
	# echo "${bold}bct_functions.py ${sparedPath}/${ID}_mean_FA_connectome.csv ${ID}_mean_FA ${pro_Path}${normal}"
	# bct_functions.py ${sparedPath}/${ID}_mean_FA_connectome.csv ${ID}_mean_FA ${pro_Path}
	
	
	echo ""
echo ""
done

echo " "
echo "${bold}Done! Have a nice day :D ${normal}"


cd ${currPath}
# Now pause and QC check output!
 ) 2>&1 | tee $subjectsPath/out_logs/${codeName}.out
