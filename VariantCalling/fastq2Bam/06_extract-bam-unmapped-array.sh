#!/bin/bash --login
#SBATCH --job-name="unmap"      # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=2		# number of cores per job
#SBATCH --mem=80G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=20:00:00			# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o bwa_%A_%a.o          # standard output bwa_%A_%a.o
#SBATCH -e bwa_%A_%a.e          # standard error bwa_%A_%a.e
#SBATCH --array=1-237       	# job array

REF=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/reference_genome/GCA_032172095.1_APGP_CSIRO_Spis_v1_genomic.fna
INDIR=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/fastq2Bam/markedRG_bamUSE
OUTDIR=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/fastq2Bam/unmapped_bamUSE

# Pull in all the files within directory. This will include path to file!
FILES=($(ls -1 ${INDIR}/*.bam))

# Allows slurm to enter the files into the job array
FILENAME=${FILES[$SLURM_ARRAY_TASK_ID]}
BASE=`basename ${FILENAME} _markedRG.bam`

echo "My input file is ${FILENAME}"

module load samtools/1.13-gcc-10.3.0

echo ${FILENAME} >> ${OUTDIR}/sample_name.txt		# generate sample names
samtools view -c ${FILENAME} >> ${OUTDIR}/allCounts.txt		# generate read counts
samtools view -b -f 12 -F 256 ${FILENAME} > ${OUTDIR}/${BASE}.unmapped.bam		# generate bam
samtools view -c ${OUTDIR}/${BASE}.unmapped.bam >> ${OUTDIR}/unmappedCounts.txt		# generate unmapped read counts
