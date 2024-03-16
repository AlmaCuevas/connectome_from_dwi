#!/bin/bash

# Create scripts for each subject to push freesurfer job onto e2 for each subject.

subjects='25 143 0 154 1 183 17 21 23 83 107 120 127 146' # AC - 20211201, the ones that doesn't have post were deleted

currpath=`pwd`
outdir=/root_folder/here/e2_jobs
stepName=connectome_spared_post

mkdir -p $outdir

for ID in ${subjects} ; do

	echo ${ID}
	subj_file=${ID}_e2_${stepName}_job.sh
	job_out=${ID}_e2_${stepName}_job.out

	if [ -f ${outdir}/${subj_file} ] ; then
		rm ${outdir}/${subj_file}
	fi

	cat > ${outdir}/${subj_file} <<'endmsg'
#!/bin/bash

#SBATCH --partition=XXXX		# queue to be used
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
	echo "${stepName}.sh /root_folder/here/ ${ID} >> ${outdir}/${ID}_${stepName}_job.out	# ${ID}_${stepName}_job.out contains echos from ${stepName}.sh" >> ${outdir}/${subj_file}
	echo "" >> ${outdir}/${subj_file}
	chmod u+wrx ${outdir}/${subj_file}
done

cat << EOF > ${outdir}/loop_sbatch_${stepName}.sh
#!/bin/bash

subjects='25 143 0 154 1 183 17 21 23 83 107 120 127 146' # AC - 20211201, the ones that doesn't have post were deleted
for ID in ${subjects} ; do

echo "sbatch ${outdir}/{ID}_e2_${stepName}_job.sh" # Manually add the $
sbatch ${outdir}/{ID}_e2_${stepName}_job.sh # Manually add the $

done
EOF
