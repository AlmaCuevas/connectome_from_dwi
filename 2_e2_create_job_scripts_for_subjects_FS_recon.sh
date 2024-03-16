#!/bin/bash

# Create scripts for each subject to push freesurfer job onto e2 for each subject.

subjects='25_pre 95_pre 143_pre 0_pre 89_pre 183_pre 154_pre 1_pre 4_pre 9_pre 17_pre 20_pre 21_pre 23_pre 83_pre 107_pre 120_pre 126_pre 127_pre 128_pre 146_pre 25_post 95_post 143_post 0_post 183_post 154_post 1_post 17_post 20_post 21_post 23_post 83_post 107_post 120_post 127_post 146_post' # AC - 20210928

currpath=`pwd`
outdir=/root_folder/here/FreeSurfer_jobs


mkdir -p $outdir

for ID in ${subjects} ; do

	echo ${ID}
	subj_file=${ID}_e2_FS_job.sh
	job_out=${ID}_e2_FS_job.out

	if [ -f ${outdir}/${subj_file} ] ; then
		rm ${outdir}/${subj_file}
	fi

	cat > ${outdir}/${subj_file} <<'endmsg'
#!/bin/bash

#SBATCH --partition=XXX		# queue to be used
#SBATCH --account=XXX
#SBATCH --time=XXX                         # Running time (in hours-minutes-seconds)
#SBATCH --mail-type=BEGIN,END,FAIL              # send and email when the job begins, ends or fails
#SBATCH --mail-user=XXXX          # Email address to send the job status
#SBATCH --nodes=X                               # Number of compute nodes
#SBATCH --ntasks=X                             # Number of cpu cores on one node
endmsg

	echo "#SBATCH --output=${job_out}		# Name of the output file" >> ${outdir}/${subj_file}
	echo "#SBATCH --job-name=${ID}			# Job name" >> ${outdir}/${subj_file}

	echo "" >> ${outdir}/${subj_file}

	echo "cd /root_folder/here/" >> ${outdir}/${subj_file}
	echo "pwd" >> ${outdir}/${subj_file}

	echo "" >> ${outdir}/${subj_file}
	echo "qc_freesurfer.sh /root_folder/here/COMPILED_RAW/${ID}_RAW_T1W.nii.gz /root_folder/here/${ID} >> ${outdir}/${ID}_FS_job.out	# ${ID}_FS_job.out contains echos from qc_freesurfer.sh" >> ${outdir}/${subj_file}
	echo "" >> ${outdir}/${subj_file}
	chmod u+wrx ${outdir}/${subj_file}
done
