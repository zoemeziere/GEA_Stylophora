#!/bin/bash --login
#SBATCH --job-name="bwa_map"    # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=2		# number of cores per job
#SBATCH --mem=500G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=24:00:00			# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name

#SBATCH -o bwa_%A_%a.o          # standard output
#SBATCH -e bwa_%A_%a.e          # standard error
#SBATCH --array=1-237        	# job array

LIST=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/fastq2Bam/fastqClean
INDIR=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/fastq2Bam/fastq_clean
OUTDIR=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/fastq2Bam/markedRG_bamUSE
REF=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/reference_genome/GCA_032172095.1_APGP_CSIRO_Spis_v1_genomic.fna

# Remember to first make bwa index from reference genome!
# bwa index *.fasta

# file name variable is associated Array index
FILENAME=`cat ${LIST} | tail -n +${SLURM_ARRAY_TASK_ID} | head -1`
BASE=`basename ${FILENAME} _R1_paired.fastq.gz`

# execute bwa using only paired reads
module load bwa/0.7.17-gcc-10.3.0
module load samtools/1.13-gcc-10.3.0

# map paired reads to reference genome
bwa mem -t 2 ${REF} ${INDIR}/${BASE}_R1_paired.fastq.gz ${INDIR}/${BASE}_R2_paired.fastq.gz > ${OUTDIR}/${BASE}.sam

# create sorted bam
samtools view -b ${OUTDIR}/${BASE}.sam > ${OUTDIR}/${BASE}_UNSORTED.bam
samtools sort ${OUTDIR}/${BASE}_UNSORTED.bam -O BAM -o ${OUTDIR}/${BASE}_UNDEDUP.bam

# removed temp files
rm ${OUTDIR}/${BASE}_UNSORTED.bam
rm ${OUTDIR}/${BASE}.sam
