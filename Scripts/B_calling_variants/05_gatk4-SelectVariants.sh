#!/bin/bash --login
#SBATCH --job-name="sVar"       # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4		# number of cores per job
#SBATCH --mem=10G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=10:00:00			# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o sVar_%A_%a.o            	# standard output
#SBATCH -e sVar_%A_%a.e	       		# standard error

module load gatk/4.3.0.0-gcccore-11.3.0-java-11

REF=/scratch/project_mnt/S0078/WGS_Stylophora_Taxon1/reference_genome/GCA_032172095.1_APGP_CSIRO_Spis_v1_genomic.fna
DB_PATH=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/gatk4-database
# CHROM=/scratch/project/rrap_ahya/analysis/gatk4/combineGVCF/test/intervals.list
# LIST=/scratch/project/rrap_ahya/analysis/gatk4/combineGVCF/lists/sampleMap_ECT_c5_503

# make index file
gatk IndexFeatureFile --input ${DB_PATH}/genotype_genomicDBI_Spis_gather.vcf.gz

# Notes:
# include nonvariant sites (default)
# --select-type-to-include SNP : select SNPS only (exclude indels)
# --exclude-sample-expressions list : to exclude samples

gatk --java-options "-Xms10G -Xmx10G -XX:ParallelGCThreads=4" SelectVariants \
  --reference ${REF} \
  --variant ${DB_PATH}/genotype_genomicDBI_Spis_gather.vcf.gz \
  --select-type-to-include SNP \
  --output ${DB_PATH}/genotype_genomicDBI_Spis_gather_noreplicates_snp.vcf.gz \
  --exclude-sample-name /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/call_variants_GATK/exclude_samples.arg 

gatk IndexFeatureFile --input ${DB_PATH}/genotype_genomicDBI_Spis_gather_noreplicates_snp.vcf.gz

echo "Job complete!"  
