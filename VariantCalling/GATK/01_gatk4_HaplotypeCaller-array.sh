#!/bin/bash --login
#SBATCH --job-name="hapCal"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4		# number of cores per job
#SBATCH --mem=80G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=100:00:00		# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o hapC_%A_%a.o         # standard output
#SBATCH -e hapC_%A_%a.e	        # standard error
#SBATCH --array=1-237        	# job array

module load gatk/4.3.0.0-gcccore-11.3.0-java-11
#module load anaconda3/2022.05
#source activate gatk4

REF=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/reference_genome/GCA_032172095.1_APGP_CSIRO_Spis_v1_genomic.fna
INDIR=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/fastq2Bam/markedRG_bamUSE
LIST=/scratch/project/phd_coral_genomics/WGS_Stylophora_all/fastq2Bam/bamList

# first need to make samtools index of genome (output=genome.fai)
# module load samtools/1.13-gcc-10.3.0
# samtools faidx reference.fa 
 
# then make gatk reference direcotry (output= genome.dict)
# module load anaconda3/2022.05
# source activate gatk4
# gatk CreateSequenceDictionary -R ${REF} -O GCA_020536085.1_Ahyacinthus.chrsV1_genomic.dict

# Pull in all the files within directory. This will include path to file!
FILES=($(ls -1 ${INDIR}/*_markedRG.bam)) 
FILENAME=${FILES[$SLURM_ARRAY_TASK_ID]} 
echo "My input file is ${FILENAME}"
