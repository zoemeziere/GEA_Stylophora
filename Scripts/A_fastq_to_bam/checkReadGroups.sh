#!/bin/bash --login
#SBATCH --job-name="checkRG"      # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=1               # number of cores per job
#SBATCH --mem=10G                               # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=4:00:00                  # walltime
#SBATCH --account=a_riginos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o reads_%A_%a.o        # standard output
#SBATCH -e reads_%A_%a.e            # standard error
#SBATCH --array=1-474                   # job array

cd markedRG_bamUSE

module load samtools/1.13-gcc-10.3.0

for FILENAME in *markedRG.bam; do
samtools view -H ${FILENAME} | grep '^@RG'
done
