#!/bin/bash --login
#SBATCH --job-name="genDB"      # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=2		# number of cores per job
#SBATCH --mem=10G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=50:00:00		# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o dbi_%A_%a.o          # standard output
#SBATCH -e dbi_%A_%a.e	        # standard error
#SBATCH --array=1-149        	# job array only scaffolds >= 10k should be 1650-4149

module load gatk/4.3.0.0-gcccore-11.3.0-java-11
# Requires intervals list for GATK to specify chromosomes to be used: 
# First execute **fasta2bed.sh** on reference genome. 
# Then execute **picard-get-interval.sh** using the BED file and the reference genome as input

cd individualGVCF

REF=/scratch/project_mnt/S0078/WGS_Stylophora_Taxon1/reference_genome/GCA_032172095.1_APGP_CSIRO_Spis_v1_genomic.fna
LIST=/scratch/project_mnt/S0078/WGS_Stylophora_Taxon1/call_variants_GATK/sampleMap
CHROM=/scratch/project_mnt/S0078/WGS_Stylophora_Taxon1/reference_genome/intervals.list.ordered.4001-4150

# file name variable is associated Array index
FILENAME=`cat ${CHROM} | tail -n +${SLURM_ARRAY_TASK_ID} | head -1`

#echo "My interval is ${FILENAME}"

# create temp directory. Refer to RCC guidelines
mkdir -p /scratch/user/uqzmezie/$SLURM_JOB_ID/tmp

gatk --java-options "-Djava.io.tmpdir=/scratch/user/uqzmezie/tmp/$SLURM_JOB_ID -Xms10G -Xmx10G -XX:ParallelGCThreads=2" GenomicsDBImport \
  --sample-name-map ${LIST} \
  --reference ${REF} \
  --intervals ${FILENAME} \
  --genomicsdb-workspace-path /scratch/project_mnt/S0078/WGS_Stylophora_Taxon1/gatk4-database/genomicDBI_${FILENAME} \
  --tmp-dir /scratch/user/uqzmezie/$SLURM_JOB_ID/tmp \
  --batch-size 50 \

echo "Job complete!"
