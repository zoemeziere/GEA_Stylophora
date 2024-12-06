#!/bin/bash --login
#SBATCH --job-name="plink"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4		# number of cores per job
#SBATCH --mem=80G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=10:00:00		# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o plink.o         # standard output
#SBATCH -e plink.e	        # standard error

module load plink/2.00a3.6-gcc-11.3.0

# Prune data

plink2 --vcf Spis_noreplicates_badsamples_filtered_linked.vcf \
	--double-id \
	--allow-extra-chr \
	--set-missing-var-ids @:# \
	--indep-pairwise 200 20 0.5 \
	--out Spis_noreplicates_badsamples_filtered_prunned

plink2 --vcf Spis_noreplicates_badsamples_filtered_linked.vcf \
	--double-id \
	--allow-extra-chr \
	--set-missing-var-ids @:# \
	--extract Spis_noreplicates_badsamples_filtered_prunned.prune.in \
	--make-bed \
	--out Spis_noreplicates_badsamples_filtered_prunned \
	--pca \
	--recode vcf
 
