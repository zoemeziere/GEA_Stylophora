#!/bin/bash --login
#SBATCH --job-name="gea"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4		# number of cores per job
#SBATCH --mem=100G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=1:00:00		# walltime
#SBATCH --account=a_senv_mbos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o gea_%A.o         # standard output
#SBATCH -e gea_%A.e	        # standard error

module load r/4.4.0-gfbf-2023a

Rscript - <<EOF

library(foreach)
library(parallel)
library(doParallel)
library(data.table)
library(pbmcapply)
library(psych)

cl <- makeCluster(12, type="FORK")
registerDoParallel(cl)

env_mat <- read.csv("site_env_data_CentralOffshore.csv", header=TRUE)
env_mat <- as.data.frame(env_mat)

af_mat <- readRDS("af_mat.rds")

# Reorder columns in env_mat to match rows in af_mat (populations)
env_mat <- env_mat[match(rownames(af_mat), env_mat[, 1]), ]
identical(env_mat[, 1], rownames(af_mat))

# Make wrapper function for cor.test to return the summary stat and the p-value as a vector
cor_test_wrapper <- function(p_vec, env_vector){
  correlation_result <- cor.test(p_vec, env_vector, method = "kendall", exact = F)
  return(c(correlation_result$'estimate',
           correlation_result$'p.val'))
}

# Use the apply function to use the wrapper function on each line of the DF - this step takes a while...
cor_results <- apply(as.matrix(af_mat), 2,
               function(x) cor_test_wrapper(x, env_mat$'temp_mean'))

# transpose the result and store as a dataframe
cor_results <- as.data.frame(t(cor_results))

# give the column informative names
names(cor_results) <- c("Kendall", "p_val")

# Save these to the output dir
saveRDS(cor_results,"cor_results.rds")

EOF
