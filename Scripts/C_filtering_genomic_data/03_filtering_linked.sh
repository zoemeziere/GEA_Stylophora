#!/bin/bash --login
#SBATCH --job-name="vcftoolsLinked"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4		# number of cores per job
#SBATCH --mem=80G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=10:00:00		# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o vcftoolsLinked_%A_%a.o         # standard output
#SBATCH -e vcftoolsLinked_%A_%a.e	        # standard error

module load vcftools

#vcftools --gzvcf /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/gatk4-database/genotype_genomicDBI_Spis_gather_snp.vcf.gz \
#--remove exclude_samples.txt \
#--recode \
#--stdout | gzip -c > Spis_noreplicates_badsamples_nofilters_linked.vcf.gz \

#gunzip -c Spis_noreplicates_badsamples_nofilters_linked.vcf.gz > Spis_noreplicates_badsamples_nofilters_linked.vcf

vcftools --gzvcf /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/filtering_vcftools/02_basic_filtering/Spis_noreplicates_badsamples_nofilters_linked.vcf.gz \
       --min-alleles 2 \
       --max-alleles 2 \
       --mac 3 \
       --minQ 30 \
       --max-missing 0.8 \
       --min-meanDP 10 \
       --max-meanDP 30 \
       --minGQ 20 \
       --remove-indels \
       --recode \
       --stdout | gzip -c > Spis_noreplicates_badsamples_filtered_linked.vcf.gz \

gunzip -c Spis_noreplicates_badsamples_filtered_linked.vcf.gz > Spis_noreplicates_badsamples_filtered_linked.vcf

vcftools --gzvcf /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/filtering_vcftools/02_basic_filtering/Spis_noreplicates_badsamples_nofilters_linked.vcf.gz \
	--min-alleles 2 \
	--max-alleles 2 \
	--mac 3 \
	--minQ 30 \
	--max-missing 1 \
	--min-meanDP 10 \
	--max-meanDP 30 \
	--minGQ 20 \
	--remove-indels \
	--recode \
	--stdout | gzip -c > Spis_noreplicates_badsamples_filtered_nomissingdata_linked.vcf.gz \

gunzip -c Spis_noreplicates_badsamples_filtered_nomissingdata_linked.vcf.gz > Spis_noreplicates_badsamples_filtered_nomissingdata_linked.vcf

module load bcftools/1.15.1-gcc-11.3.0

bcftools filter --exclude 'ALT="*" || type!="snp"' Spis_noreplicates_badsamples_filtered_linked.vcf -o Spis_noreplicates_badsamples_filtered_linked_noDel.vcf.gz
bcftools filter --exclude 'ALT="*" || type!="snp"' Spis_noreplicates_badsamples_filtered_nomissingdata_linked.vcf -o Spis_noreplicates_badsamples_filtered_nomissingdata_linked_noDel.vcf.gz
