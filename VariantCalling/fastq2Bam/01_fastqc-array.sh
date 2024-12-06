#!/bin/bash --login
#SBATCH --job-name="fastqc"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1		# use 1 for single and multi core jobs
#SBATCH --cpus-per-task=1		# number of cores per job
#SBATCH --mem=100G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=20:00:00			# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o fqc_%A_%a.o          # standard output
#SBATCH -e fqc_%A_%a.e	        # standard erro

module load fastqc/0.11.9-java-11


fastqc --extract /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/fastq_files/* -f fastq -o fastqc_output
