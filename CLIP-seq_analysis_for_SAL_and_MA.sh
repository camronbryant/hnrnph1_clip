#!/bin/bash -l

#$ -P johnsonlab
#$ -j y
#$ -pe omp 8
#$ -l mem_per_core=16G
#$ -N clam_analysis
#$ -o clam_analysis.log

echo "=========================================================="
echo "Starting on : $(date)"
echo "Running on node : $(hostname)"
echo "Current directory : $(pwd)"
echo "Current job ID : $JOB_ID"
echo "Current job name : $JOB_NAME"
echo "=========================================================="

# Load modules
module load python3/3.6.5
module load clam/1.2
module load bedtools/2.27.1

# Define directories
OUTDIR="../../../CLAM"
PEAKDIR="peaks_100"
GTF="../../gencode_GRCm38_genome/data/GRCm38_genome/annotation/gencode.vM23.primary_assembly.annotation.gtf"

# ---------------------------
# Preprocessing
# ---------------------------
for file in *_final.bam; do
    base=$(basename "${file}" _final.bam)
    echo "Preprocessing ${file}..."
    CLAM preprocessor -i "${file}" -o "${OUTDIR}/${base}" --read-tagger-method start
done

# ---------------------------
# Realignment
# ---------------------------
samples=(CLIP_WT_S_{1..3} CLIP_WT_M_{1..3} input_merge_WT_S input_merge_WT_M)

for sample in "${samples[@]}"; do
    echo "Realigning ${sample}..."
    CLAM realigner -i "${sample}/" -o "${sample}/" --winsize 50 --max-tags -1 --read-tagger-method start
done

# ---------------------------
# Peak Calling
# ---------------------------
declare -A conditions=(
    [WT_S]="CLIP_WT_S_1 CLIP_WT_S_2 CLIP_WT_S_3 input_merge_WT_S"
    [WT_M]="CLIP_WT_M_1 CLIP_WT_M_2 CLIP_WT_M_3 input_merge_WT_M"
)

for cond in "${!conditions[@]}"; do
    echo "Peak calling for ${cond}..."
    reps=(${conditions[$cond]})
    uniq_bams=$(printf "%s/unique.sorted.bam," "${reps[@]}")
    realign_bams=$(printf "%s/realigned.sorted.bam," "${reps[@]}")

    # Remove trailing commas
    uniq_bams=${uniq_bams%,}
    realign_bams=${realign_bams%,}

    # First three are replicates, last one is input control
    CLAM peakcaller -i "${uniq_bams}" "${realign_bams}" \
        -c "${reps[-1]}/unique.sorted.bam" "${reps[-1]}/realigned.sorted.bam" \
        -o "${PEAKDIR}/${cond}" --binsize 100 --gtf "${GTF}"
done

# ---------------------------
# Annotation
# ---------------------------
for cond in WT_S WT_M; do
    echo "Annotating peaks for ${cond}..."
    CLAM peak_annotator -i "${PEAKDIR}/${cond}/narrow_peak.combined.bed" \
        -g mm10 -o "${PEAKDIR}/${cond}/${cond}_annotated_peak.txt"
done

echo "finished"
echo "=========================================================="
echo "Finished on : $(date)"
echo "=========================================================="