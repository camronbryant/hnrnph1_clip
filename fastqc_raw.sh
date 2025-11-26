#!/bin/bash -l

#$ -P johnsonlab	    #specify project name
#$ -j y			        #merge the error and output stream files into a single file
#$ -l h_rt=48:00:00	    #set run time limit
#$ -N fastqc_raw	    #this is the job name
#$ -o fastqc_raw.log	#NOTE:create a log directory first before running the script


echo "=========================================================="
echo "Starting on : $(date)"
echo "Running on node : $(hostname)"
echo "Current directory : $(pwd)"
echo "Current job ID : $JOB_ID"
echo "Current job name : $JOB_NAME"
echo "=========================================================="


module load fastqc/0.11.7

output=/restricted/projectnb/johnsonlab/qiu/clip/fastqc_raw
for file in /restricted/projectnb/johnsonlab/qiu/clip/data/*_001.fastq.gz
do
fastqc -f fastq -o ${output} ${file}
done

echo "finished"

echo "=========================================================="
echo "Finished on : $(date)"
echo "=========================================================="