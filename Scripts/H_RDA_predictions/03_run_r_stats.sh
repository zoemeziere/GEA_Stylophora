#!/bin/bash --login
#SBATCH --job-name="RDA"     
#SBATCH --nodes=1              
#SBATCH --ntasks-per-node=1    
#SBATCH --cpus-per-task=4      
#SBATCH --mem=300G
#SBATCH --time=24:00:00
#SBATCH --account=a_riginos
#SBATCH --partition=general
#SBATCH -o rda_stat_%A.o
#SBATCH -e rda_stat_%A.e

module load r/4.2.1-foss-2022a

Rscript stat_RDA_models.R $1

# use as sbatch 03_run_r_stats.sh Heron
