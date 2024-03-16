#!/bin/bash

# Create scripts for each subject to push qc_prep_v2.0.sh

currpath=`pwd`
outdir=/root_folder/here/out_logs

declare -a subjects=()
declare -a from_original_ini_copy=() # Individual subject original file names

subjects[0]="25_pre"
from_original_ini_copy[0]="000XX-ORIGINAL_NAME"

subjects[1]="25_post"
from_original_ini_copy[1]="000XX-ORIGINAL_NAME"

subjects[2]="95_pre"
from_original_ini_copy[2]="000XX-ORIGINAL_NAME"

subjects[3]="95_post"
from_original_ini_copy[3]="000XX-ORIGINAL_NAME"

subjects[4]="143_pre"
from_original_ini_copy[4]="000XX-ORIGINAL_NAME"

subjects[5]="143_post"
from_original_ini_copy[5]="000XX-ORIGINAL_NAME"

subjects[6]="0_pre"
from_original_ini_copy[6]="000XX-ORIGINAL_NAME"

subjects[7]="0_post"
from_original_ini_copy[7]="000XX-ORIGINAL_NAME"

subjects[8]="89_pre"
from_original_ini_copy[8]="000XX-ORIGINAL_NAME"

subjects[9]="89_post"
from_original_ini_copy[9]="" # Not Available

subjects[10]="183_pre"
from_original_ini_copy[10]="000XX-ORIGINAL_NAME"

subjects[11]="183_post"
from_original_ini_copy[11]="000XX-ORIGINAL_NAME"

subjects[12]="154_pre"
from_original_ini_copy[12]="000XX-ORIGINAL_NAME"

subjects[13]="154_post"
from_original_ini_copy[13]="000XX-ORIGINAL_NAME"

subjects[14]="1_pre"
from_original_ini_copy[14]="000XX-ORIGINAL_NAME"

subjects[15]="1_post"
from_original_ini_copy[15]="000XX-ORIGINAL_NAME"

subjects[16]="4_pre"
from_original_ini_copy[16]="000XX-ORIGINAL_NAME"

subjects[17]="4_post"
from_original_ini_copy[17]="" # Not Available

subjects[18]="9_pre"
from_original_ini_copy[18]="" # Not Available (yet)

subjects[19]="9_post"
from_original_ini_copy[19]="" # Not Available

subjects[20]="17_pre"
from_original_ini_copy[20]="000XX-ORIGINAL_NAME"

subjects[21]="17_post"
from_original_ini_copy[21]="000XX-ORIGINAL_NAME"

subjects[22]="20_pre"
from_original_ini_copy[22]="000XX-ORIGINAL_NAME"

subjects[23]="20_post"
from_original_ini_copy[23]="" # Not Available 

subjects[24]="21_pre"
from_original_ini_copy[24]="000XX-ORIGINAL_NAME"

subjects[25]="21_post"
from_original_ini_copy[25]="000XX-ORIGINAL_NAME"

subjects[26]="23_pre"
from_original_ini_copy[26]="000XX-ORIGINAL_NAME"

subjects[27]="23_post"
from_original_ini_copy[27]="000XX-ORIGINAL_NAME"

subjects[28]="83_pre"
from_original_ini_copy[28]="000XX-ORIGINAL_NAME"

subjects[29]="83_post"
from_original_ini_copy[29]="000XX-ORIGINAL_NAME"

subjects[30]="107_pre"
from_original_ini_copy[30]="000XX-ORIGINAL_NAME"

subjects[31]="107_post"
from_original_ini_copy[31]="000XX-ORIGINAL_NAME"

subjects[32]="120_pre"
from_original_ini_copy[32]="000XX-ORIGINAL_NAME"

subjects[33]="120_post"
from_original_ini_copy[33]="000XX-ORIGINAL_NAME"

subjects[34]="126_pre"
from_original_ini_copy[34]="000XX-ORIGINAL_NAME"

subjects[35]="126_post"
from_original_ini_copy[35]="" # Not Available

subjects[36]="127_pre"
from_original_ini_copy[36]="000XX-ORIGINAL_NAME"

subjects[37]="127_post"
from_original_ini_copy[37]="000XX-ORIGINAL_NAME"

subjects[38]="128_pre"
from_original_ini_copy[38]="000XX-ORIGINAL_NAME"

subjects[39]="128_post"
from_original_ini_copy[39]="" # Not Available

subjects[40]="146_pre"
from_original_ini_copy[40]="000XX-ORIGINAL_NAME"

subjects[41]="146_post"
from_original_ini_copy[41]="000XX-ORIGINAL_NAME"

mkdir -p $outdir

for ((IDn=0;IDn<=${#subjects[@]};IDn++)) ; do

	ID=${subjects[${IDn}]}
	
	subj_file=${ID}_qc_Diffusion.sh
	
	if [ -f ${outdir}/${subj_file} ] ; then
		rm ${outdir}/${subj_file}
	fi

	cat > ${outdir}/${subj_file} <<'endmsg'

endmsg

	if [[ ${from_original_ini_copy[${IDn}]} != "" ]] ; then # Some patients don't have a post-surgery
	
		echo "#!/bin/bash" >> ${outdir}/${subj_file}

		echo "" >> ${outdir}/${subj_file}
		echo "dMRI_pipeline_prep_files.sh ${ID} /root_folder/here/${ID} ${from_original_ini_copy[${IDn}]} /root_folder/here/COMPILED_RAW /root_folder/here/diffusion_params.ini >> ${outdir}/${ID}_qc_Diffusion.out" >> ${outdir}/${subj_file}
		chmod u+wrx ${outdir}/${subj_file}
	fi
done
