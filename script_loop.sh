#!/bin/bash

# Bold
bold=$(tput bold)
normal=$(tput sgr0)

if [ $# -eq 0 ] ; then
	echo " "
	echo " "
	echo "Author: AC"
	echo " "
	echo "	Run the Diffusion scripts created in 3_create_scripts_Diffusion.sh"
	echo " "
	echo "	3_loop_diffusion.sh < %s subjects_folder > <%s scripts_folder > < %s bash_script >"
	echo " "
	echo "	%s subjects_folder	: Root folder where all the subjects folders (and names) are"
	echo "					This code will only detect if the name contains numbers, underscore and a 'pre' or 'post'"
	echo "  %s scripts_folder	: Folder name of scripts to run"
	echo "  %s bash_script		: Complementary name of the bash scripts to run (with the .sh)"
	echo "					example: '_qc_Diffusion.sh' or '_qcprep_job.sh'"
	echo " "
	exit 1
fi

if [ $# -ne 3 ]; then
	echo "ERROR :::: $# arguments entered to call script_loop.sh when expecting 3"
	script_loop.sh
	exit 1
fi

subject_dir=$1
#subject_dir='/root_folder/here/'
script_folder=${2:-out_logs}
script_name=$3

subject_list=$(find ${subject_dir} -maxdepth 1 -mindepth 1 -type d -regex ".*[0-9]+[_]+[p]+[r]*[e]*[o]*[s]*[t]*" -exec basename {} \;) #regex pattern matches anything with numbes, underscore and the letters preost (to form pre or post)

echo " "
echo "${bold}The following subjects were found:${normal}"
printf "%s\n" ${subject_list}

cd ${subject_dir}

echo " "
echo "${bold}Running the following scripts:${normal}"

for ID in ${subject_list} ; do
	echo "${script_folder}/${ID}${script_name}"
	bash ${subject_dir}/${script_folder}/${ID}${script_name}
done

echo " "
echo "${bold}OUTPUT: The outputs of the script function ID${script_name} ${normal}"
