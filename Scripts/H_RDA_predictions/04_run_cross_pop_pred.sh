#!/bin/bash --login
#SBATCH --job-name="testRDA"     
#SBATCH --nodes=1              
#SBATCH --ntasks-per-node=1    
#SBATCH --cpus-per-task=4      
#SBATCH --mem=100G
#SBATCH --time=5:00:00
#SBATCH --account=a_senv_mbos
#SBATCH --partition=general
#SBATCH -o testrda_%A.o
#SBATCH -e testrda_%A.e

module load r/4.2.1-foss-2022a

Rscript cross_pop_pred.R
