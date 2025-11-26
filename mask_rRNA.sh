#!/bin/bash -l

#$ -P johnsonlab
#$ -j y
#$ -l h_rt=48:00:00
#$ -N bedtools_mask_rRNA
#$ -o bedtools_mask_rRNA.log

set -euo pipefail

echo "=========================================================="
echo "Starting on : $(date)"
echo "Running on node : $(hostname)"
echo "Current directory : $(pwd)"
echo "Current job ID : $JOB_ID"
echo "Current job name : $JOB_NAME"
echo "=========================================================="

module load bedtools/2.27.1

mkdir -p ../../mask_rRNA/pe

for file in *_onlychr.bam; do
    base=$(basename "${file}" _onlychr.bam)
    echo "Processing ${file}..."
    bedtools intersect -f 0.90 -abam "${file}" \
        -b ../../../../UCSC_repeatmasker/UCSC_repeatmasker_track.bed -v \
        > ../../mask_rRNA/pe/${base}_onlychr_mask_rRNA.bam
done

echo "finished"
echo "=========================================================="
echo "Finished on : $(date)"
echo "=========================================================="

