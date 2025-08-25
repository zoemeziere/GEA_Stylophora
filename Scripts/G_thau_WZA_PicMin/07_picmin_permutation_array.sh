#!/bin/bash --login
#SBATCH --job-name="picmin_perm"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=500G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=72:00:00         # walltime
#SBATCH --account=a_riginos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH --array=1-1000
#SBATCH -o picmin_perm_%A.o         # standard output
#SBATCH -e picmin_perm_%A.e             # standard error

module load r/4.2.1-foss-2022a

# Run your R script and pass the array task ID as a variable
Rscript 05_picmin_permutation.R $SLURM_ARRAY_TASK_ID
