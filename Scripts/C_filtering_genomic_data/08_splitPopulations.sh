#!/bin/bash --login
#SBATCH --job-name="splitpop"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4		# number of cores per job
#SBATCH --mem=80G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=5:00:00		# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o splitpop_%A_%a.o         # standard output
#SBATCH -e splitpop_%A_%a.e	        # standard error

module load vcftools

for pop in $(find ind_*)
do

   vcftools --vcf /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/filtering_vcftools/02_basic_filtering/Spis_noreplicates_badsamples_nofilters_linked.vcf \
	--keep $pop \
	--recode \
	--stdout | gzip -c > /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/filtering_vcftools/04_populations/Spis_${pop}.vcf.gz \

done

#vcftools --vcf /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/filtering_vcftools/02_basic_filtering/Spis_noreplicates_badsamples_nofilters_linked.vcf \
#	--keep ind_OffshoreCentral \
#	--recode \
#	--stdout | gzip -c > /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/filtering_vcftools/04_populations/Spis_ind_OffshoreCentral_nomissingdata.vcf.gz \

#vcftools --vcf /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/filtering_vcftools/02_basic_filtering/Spis_noreplicates_badsamples_nofilters_linked.vcf \
#        --keep ind_Pelorus \
#        --recode \
#        --stdout | gzip -c > /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/filtering_vcftools/04_populations/Spis_ind_Pelorus_nomissingdata.vcf.gz \

