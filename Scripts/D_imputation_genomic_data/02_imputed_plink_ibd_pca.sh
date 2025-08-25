#!/bin/bash --login
#SBATCH --job-name="ibd"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4		# number of cores per job
#SBATCH --mem=80G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=03:00:00		# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o ibd.o         # standard output
#SBATCH -e ibd.e	        # standard error

module load plink/2.00a3.6-gcc-11.3.0

# IBD
#plink2 --vcf /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/filtering_vcftools/02_basic_filtering/Spis_all_filtered_pruned.vcf --distance 1-ibs --out Spis_all_filtered_pruned

# PCA
plink2 --vcf /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/filtering_vcftools/02_basic_filtering/Spis_noreplicates_badsamples_filtered_prunned.vcf --allow-extra-chr --make-bed 
plink2 --bfile Spis_noreplicates_badsamples_filtered_prunned --pca
