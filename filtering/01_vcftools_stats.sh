#!/bin/bash --login
#SBATCH --job-name="vcftools"      # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=1		# number of cores per job
#SBATCH --mem=100G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=24:00:00			# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o vcftools.o         # standard output
#SBATCH -e vcftools.e         # standard error

#mkdir vcftools
#cd vcftools

module load bcftools

#bcftools view -H /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/gatk4-database/genotype_genomicDBI_Spis_gather.vcf.gz | wc -l
#40,100,811

VCF=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/gatk4-database/genotype_genomicDBI_Spis_gather.vcf.gz
OUT=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/call_variants_GATK/vcftools

module load vcftools

vcftools --gzvcf $VCF --freq2 --out $OUT --max-alleles 2
vcftools --gzvcf $VCF --site-mean-depth --out $OUT
vcftools --gzvcf $VCF --depth --out $OUT
vcftools --gzvcf $VCF --site-quality --out $OUT
vcftools --gzvcf $VCF --missing-indv --out $OUT
vcftools --gzvcf $VCF --missing-site --out $OUT
vcftools --gzvcf $VCF --het --out $OUT
