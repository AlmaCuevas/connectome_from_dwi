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
	echo "	bct_functions.sh < %s subjects_folder >"
	echo " "
	echo "	%s subjects_folder	: Root folder where all the subjects folders (and names) are"
	echo "					This code will only detect if the name contains numbers, underscore and a 'pre' or 'post'"
	echo " "
	exit 1
fi

if [ $# -ne 1 ]; then
	echo "ERROR :::: $# arguments entered to call script_loop.sh when expecting 1"
	bct_functions.sh
	exit 1
fi

subject_dir=${1:-/root_folder/here/}

subject_list='25 143 154 1 183 17 21 23 83 107 120 127 146'

echo " "
echo "${bold}The following subjects were found:${normal}"
printf "%s\n" ${subject_list}

cd ${subject_dir}

echo " "
echo "${bold}Running the following scripts:${normal}"

for ID in ${subject_list} ; do
	spared_post.sh /root_folder/here/ ${ID}
	echo "" 
echo ""
done

echo " "
echo "${bold}Done! Have a nice day :D ${normal}"
