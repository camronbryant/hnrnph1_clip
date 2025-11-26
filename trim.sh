#!/bin/bash -l

#$ -P johnsonlab
#$ -j y
#$ -l h_rt=48:00:00
#$ -l h_vmem=8G
#$ -N trim
#$ -o trim.log
#$ -t 1-3

echo "=========================================================="
echo "Starting on : $(date)"
echo "Running on node : $(hostname)"
echo "Current directory : $(pwd)"
echo "Current job ID : $JOB_ID"
echo "Current job name : $JOB_NAME"
echo "Task index number : $SGE_TASK_ID"
echo "=========================================================="

module load trimmomatic/0.36
mkdir -p ../trimmed_data

for sample in "WT-S" "WT-M" "CLIP-WT-S" "CLIP-WT-M"; do
    echo "Processing sample: ${sample}-${SGE_TASK_ID}"
    trimmomatic PE -phred33 \
        ${sample}-${SGE_TASK_ID}_L007_R1_001.fastq.gz \
        ${sample}-${SGE_TASK_ID}_L007_R2_001.fastq.gz \
        ../trimmed_data/${sample}_${SGE_TASK_ID}_R1_paired.fastq.gz \
        ../trimmed_data/${sample}_${SGE_TASK_ID}_R1_unpaired.fastq.gz \
        ../trimmed_data/${sample}_${SGE_TASK_ID}_R2_paired.fastq.gz \
        ../trimmed_data/${sample}_${SGE_TASK_ID}_R2_unpaired.fastq.gz \
        ILLUMINACLIP:/share/pkg/trimmomatic/0.36/install/adapters/TruSeq3-PE-2.fa:2:30:10 \
        LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:30
done

echo "finished"
echo "=========================================================="
echo "Finished on : $(date)"
echo "=========================================================="