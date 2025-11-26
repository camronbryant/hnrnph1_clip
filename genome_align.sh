#!/bin/bash -l

#$ -P johnsonlab
#$ -j y
#$ -pe omp 16
#$ -l mem_per_core=16G
#$ -N genome_align
#$ -o genome_align.log

echo "=========================================================="
echo "Starting on : $(date)"
echo "Running on node : $(hostname)"
echo "Current directory : $(pwd)"
echo "Current job ID : $JOB_ID"
echo "Current job name : $JOB_NAME"
echo "=========================================================="

module load gcc/8.1.0
module load star/2.7.1a

# --- Genome Indexing ---
STAR --runThreadN 8 --runMode genomeGenerate \
    --genomeDir data/GRCm38_rRNA/star_indices_overhang99/ \
    --genomeSAindexNbases 5 \
    --genomeFastaFiles data/GRCm38_rRNA/sequence/GRCm38.rrna.fa

STAR --runThreadN 16 --runMode genomeGenerate \
    --genomeDir data/GRCm38/star_indices_overhang99/ \
    --genomeFastaFiles data/GRCm38/sequence/GRCm38_r95.all.fa \
    --sjdbGTFfile data/GRCm38/annotation/Mus_musculus.GRCm38.95.gtf \
    --sjdbOverhang 99

# --- Alignment ---
outdir=../../multi_aligner/genome_align/pe
mkdir -p $outdir

for file in *_R1_umiext.fastq.gz; do
    base=$(basename ${file} _R1_umiext.fastq.gz)
    STAR --runMode alignReads \
         --runThreadN 16 \
         --limitBAMsortRAM 15000000000 \
         --genomeDir ../../../gencode_GRCm38_genome/data/GRCm38_genome/star_indices_overhang99 \
         --readFilesIn ${file} ${base}_R2_umiext.fastq.gz \
         --readFilesCommand zcat \
         --genomeLoad NoSharedMemory \
         --outReadsUnmapped Fastx \
         --outSAMunmapped Within \
         --outSAMtype BAM SortedByCoordinate \
         --outFilterScoreMinOverLread 0.3 \
         --outFilterMatchNminOverLread 0.3 \
         --outFilterMultimapNmax 20 \
         --sjdbScore 2 \
         --outFileNamePrefix ${outdir}/${base}_pe_ \
         --outLogFileName ${outdir}/${base}.log
done

echo "finished"
echo "=========================================================="
echo "Finished on : $(date)"
echo "=========================================================="