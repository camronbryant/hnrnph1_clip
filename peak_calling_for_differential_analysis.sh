#!/bin/bash -l
#$ -P johnsonlab
#$ -j y
#$ -pe omp 8
#$ -l mem_per_core=16G
#$ -N peak_calling_for_differential_analysis
#$ -o peak_calling_for_differential_analysis.log

echo "=========================================================="
echo "Starting on : $(date)"
echo "Running on node : $(hostname)"
echo "Current directory : $(pwd)"
echo "Current job ID : $JOB_ID"
echo "Current job name : $JOB_NAME"
echo "=========================================================="

# Load modules
module load python3/3.6.5
module load samtools/1.9
module load clam/1.2
module load bedtools/2.27.1

# Create output directories
mkdir -p merge_bam_for_CLAM clip_merge input_merge peaks_100/merge_peaks

# Merge BAM files
samtools merge merge_bam_for_CLAM/CLIP_WT_merge.bam \
    ../bam/CLIP_WT_S_*_final.bam \
    ../bam/CLIP_WT_M_*_final.bam

samtools merge merge_bam_for_CLAM/INPUT_WT_merge.bam \
    ../bam/INPUT_WT_S_*_final.bam \
    ../bam/INPUT_WT_M_*_final.bam

# Sort and index BAM files
samtools sort -o merge_bam_for_CLAM/CLIP_WT_merge_sort.bam merge_bam_for_CLAM/CLIP_WT_merge.bam
samtools index merge_bam_for_CLAM/CLIP_WT_merge_sort.bam

samtools sort -o merge_bam_for_CLAM/INPUT_WT_merge_sort.bam merge_bam_for_CLAM/INPUT_WT_merge.bam
samtools index merge_bam_for_CLAM/INPUT_WT_merge_sort.bam

# Preprocess
CLAM preprocessor -i merge_bam_for_CLAM/CLIP_WT_merge_sort.bam -o clip_merge/ --read-tagger-method start
CLAM preprocessor -i merge_bam_for_CLAM/INPUT_WT_merge_sort.bam -o input_merge/ --read-tagger-method start

# Realign
CLAM realigner -i input_merge/ -o input_merge/ --winsize 50 --max-tags -1 --read-tagger-method start
CLAM realigner -i clip_merge/ -o clip_merge/ --winsize 50 --max-tags -1 --read-tagger-method start

# Peak Calling
CLAM peakcaller -i clip_merge/unique.sorted.bam clip_merge/realigned.sorted.bam \
    -c input_merge/unique.sorted.bam input_merge/realigned.sorted.bam \
    -o peaks_100/merge_peaks --binsize 100 \
    --gtf ../../gencode_GRCm38_genome/data/GRCm38_genome/annotation/gencode.vM23.primary_assembly.annotation.gtf

# Annotation
CLAM peak_annotator -i peaks_100/merge_peaks/narrow_peak.combined.bed -g mm10 -o peaks_100/merge_peaks/CLIP_annotated_peak.txt

echo "=========================================================="
echo "Finished on : $(date)"
echo "=========================================================="