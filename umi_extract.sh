#!/bin/bash -l

#$ -P johnsonlab
#$ -j y
#$ -l h_rt=48:00:00
#$ -N umi_pe_extract
#$ -o umi_pe_extract.log
#$ -t 1-3

mkdir -p ../umi_extract/log

exec > >(tee -a umi_pe_extract_${SGE_TASK_ID}.log) 2>&1

echo "=========================================================="
echo "Starting on : $(date)"
echo "Running on node : $(hostname)"
echo "Current directory : $(pwd)"
echo "Current job ID : $JOB_ID"
echo "Current job name : $JOB_NAME"
echo "Task index number : $SGE_TASK_ID"
echo "=========================================================="

run_extract () {
    local prefix=$1
    ~/.local/bin/umi_tools extract --extract-method=string --bc-pattern=NNNNNNNNNN \
        -I ${prefix}_${SGE_TASK_ID}_R2_paired.fastq.gz \
        --read2-in=${prefix}_${SGE_TASK_ID}_R1_paired.fastq.gz \
        --stdout=../umi_extract/${prefix}_${SGE_TASK_ID}_R2_umiext.fastq.gz \
        --read2-out=../umi_extract/${prefix}_${SGE_TASK_ID}_R1_umiext.fastq.gz \
        -L ../umi_extract/log/${prefix}_${SGE_TASK_ID}_pe_umiext.log
}

run_extract input_WT_S &
run_extract input_WT_M &
run_extract CLIP_WT_S &
run_extract CLIP_WT_M &
wait

echo "finished"
echo "=========================================================="
echo "Finished on : $(date)"
echo "=========================================================="