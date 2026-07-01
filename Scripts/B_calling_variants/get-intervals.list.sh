#!/bin/bash --login
#SBATCH --job-name="interval.list"      # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=1	# number of cores per job
#SBATCH --mem=8G		# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=0:30:00		# walltime
#SBATCH --account=a_riginos	# group account name
#SBATCH --partition=general	# queue name
#SBATCH -o interval.list.o             # standard output
#SBATCH -e interval.list.e	        # standard error

# create interval_list file
sed -i 's/\t/:/g' GCA_032172095.1_APGP_CSIRO_Spis_v1_genomic.fna.bed
sed 's/:0:/:1-/g' GCA_032172095.1_APGP_CSIRO_Spis_v1_genomic.fna.bed > intervals.list
