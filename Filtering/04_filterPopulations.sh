#!/bin/bash --login
#SBATCH --job-name="filterpop"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4		# number of cores per job
#SBATCH --mem=100G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=24:00:00		# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o filterpop_%A_%a.o         # standard output
#SBATCH -e filterpop_%A_%a.e	        # standard error

module load vcftools

cd PopulationVCF

for vcf in *.vcf.gz;
do

   vcftools --gzvcf $vcf \
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
	--stdout | gzip -c > "${vcf%.vcf.gz}_filtered.vcf.gz" \

done
