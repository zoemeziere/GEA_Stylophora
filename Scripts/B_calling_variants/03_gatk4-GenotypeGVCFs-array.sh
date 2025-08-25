#!/bin/bash --login
#SBATCH --job-name="gvcf"       # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=2		# number of cores per job
#SBATCH --mem=10G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=10:00:00		# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o gvcf_%A_%a.o         # standard output
#SBATCH -e gvcf_%A_%a.e	        # standard error
#SBATCH --array=941-1000      		# job array     # only scaffolds >10k

module load gatk/4.3.0.0-gcccore-11.3.0-java-11

# create temp directory
mkdir -p /scratch/user/uqzmezie/$SLURM_JOB_ID/tmp

REF=/scratch/project_mnt/S0078/WGS_Stylophora_Taxon1/reference_genome/GCA_032172095.1_APGP_CSIRO_Spis_v1_genomic.fna
CHROM=/scratch/project_mnt/S0078/WGS_Stylophora_Taxon1/reference_genome/intervals.list.ordered.3001-4000
DB_PATH=/scratch/project_mnt/S0078/WGS_Stylophora_Taxon1/gatk4-database
# LIST=/scratch/project/rrap_ahya/analysis/gatk4/combineGVCF/lists/sampleMap_ECT_648_16outgroups

# file name variable is associated Array index
FILENAME=`cat ${CHROM} | tail -n +${SLURM_ARRAY_TASK_ID} | head -1`
echo "My interval is ${FILENAME}"

# Apply additional flags to retain monomorphic sites!!
# --include-non-variant-sites,-all-sites:Boolean
# Include loci found to be non-variant after genotyping  Default value: false. Possible values: {true, false} 

gatk --java-options "-Djava.io.tmpdir=/scratch/user/uqzmezie/tmp/$SLURM_JOB_ID/ -Xms10G -Xmx10G -XX:ParallelGCThreads=2" GenotypeGVCFs \
   --reference ${REF} \
   --annotation-group StandardAnnotation \
   --variant gendb:///${DB_PATH}/genomicDBI_${FILENAME} \
   --tmp-dir /scratch/user/uqzmezie/$SLURM_JOB_ID/tmp \
   --output ${DB_PATH}/genotype_genomicDBI_Spis_${FILENAME}.vcf.gz
 
echo "Job complete!"  
