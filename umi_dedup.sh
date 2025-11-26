#!/bin/bash -l

#$ -P johnsonlab		#specify project name
#$ -j y					#merge the error and output stream files into a single file
#$ -l h_rt=48:00:00		#set run time limit
#$ -N umi_dedup     	#this is the job name
#$ -o umi_dedup.log	    #NOTE:create a log directory first before running the script

echo "=========================================================="
echo "Starting on : $(date)"
echo "Running on node : $(hostname)"
echo "Current directory : $(pwd)"
echo "Current job ID : $JOB_ID"
echo "Current job name : $JOB_NAME"
echo "=========================================================="

module load samtools/1.9

mkdir -p ../../umi_dedup/pe/log

for file in *_aligned_onlychr_mask_rRNA.bam; do
	base=$(basename ${file} _aligned_onlychr_mask_rRNA.bam)
	echo "Processing ${file} -> ${base}_final.bam at $(date)"
	~/.local/bin/umi_tools dedup --method unique \
		-I ${file} \
		-S ../../umi_dedup/pe/${base}_final.bam \
		-L ../../umi_dedup/pe/log/${base}_final.log
done

echo "finished"

echo "=========================================================="
echo "Finished on : $(date)"
echo "=========================================================="