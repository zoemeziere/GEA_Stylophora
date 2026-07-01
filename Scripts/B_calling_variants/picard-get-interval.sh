#!/bin/bash --login
#SBATCH --job-name="pcd"      # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=1	# number of cores per job
#SBATCH --mem=8G		# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=2:00:00		# walltime
#SBATCH --account=a_riginos	# group account name
#SBATCH --partition=general	# queue name
#SBATCH -o pcd.o             # standard output
#SBATCH -e pcd.e	        # standard error

module load anaconda3/2022.05
source activate picard

picard BedToIntervalList \
      I=GCA_032172095.1_APGP_CSIRO_Spis_v1_genomic.fna.bed \
      O=GCA_032172095.1_APGP_CSIRO_Spis_v1_genomic.interval_list \
      SD=GCA_032172095.1_APGP_CSIRO_Spis_v1_genomic.dict
