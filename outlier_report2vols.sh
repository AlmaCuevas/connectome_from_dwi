#!/bin/bash

#__author__ = 'AC'
#__contact__ = 'XXXX'
#__date__ = '11/2021'
#__version__ = '0.1'

# This converts the outlier_report from the eddy qc to single lines for easy access

# NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOT FINISHED

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
	echo " "
	echo "DESCRIPTION:"
	echo "	- Convert the eddy_outlier_report files in a text of the outlier volumes separated by commas for the post_dwi removal"
	echo " "
	echo "PREREQUISITE:"
	echo "  	- dMRI_pipeline_dwifsl.sh has been called on subject data."
	echo "	- Expects folder structure and naming convention from dMRI pipeline."
	echo "	"
	echo "USAGE:"
	echo "	"
	echo "	outlier_report2vols.sh < %s subjects_folder >"
	echo " "
	echo "	%s subjects_folder		: Root subjects folder where the ID files can be found"
	echo "						This code will only detect if the name contains numbers, underscore and a 'pre' or 'post'"
	echo "	*Include full path*"
	echo "	"
	echo " "
	exit 1
fi

if [ $# -ne 1 ]; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: $# arguments entered to call outlier_report2vols.sh when expecting 1.${NC}"
	outlier_report2vols.sh
	exit 1
fi

if [ ! -d $subject_dir ]; then
	echo " "
	echo " "
	echo -e "${RED}ERROR ::: $subject_dir does not exist. Cannot continue.${NC}"
	outlier_report2vols.sh
	exit 1
fi

subject_dir=$1
#subject_dir=/root_folder/here/
outliers_folder=${subject_dir}/eddyqc_outliers
mkdir -p ${outliers_folder}

subject_list=$(find ${subject_dir} -maxdepth 1 -mindepth 1 -type d -regex ".*[0-9]+[_]+[p]+[r]*[e]*[o]*[s]*[t]*" -exec basename {} \;) #regex pattern matches anything with numbers, underscore and the letters preost (to form pre or post)

echo " "
echo "${bold}The following subjects were found:${normal}"
printf "%s\n" ${subject_list}

cd ${subject_dir}
rm ${subject_dir}/outfile.txt

echo " "
echo "${bold}Converting the following files:${normal}"

for ID in ${subject_list} ; do
	echo "${subject_dir}/${ID}/Diffusion/Preproc_files/Eddy/eddy_outlier_report"
	
	eddy_report="${subject_dir}/${ID}/Diffusion/Preproc_files/Eddy/eddy_outlier_report"
	rX=`grep -o 'Slice[^i]*' ${eddy_report}`
	rY=`grep -o 'scan[^i]*' ${eddy_report}`
	paste <(printf "$rX") <(printf "$rY") >> ${outliers_folder}/${ID}.outlier # paste as two columns
	grep -o ' scan[^i]*' ${eddy_report} >> ${outliers_folder}/tmp.out
	num=`sed -r 's/[^0-9]*//g' ${outliers_folder}/tmp.out`
	(echo $num) >> ${outliers_folder}/all_vols.txt
	rm ${outliers_folder}/tmp.out
	
done # Close the for







