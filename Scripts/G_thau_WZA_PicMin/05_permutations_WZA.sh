#!/bin/bash --login
#SBATCH --job-name=WZAperm
#SBATCH --array=1-1000
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=100G
#SBATCH --time=48:00:00
#SBATCH --account=a_senv_mbos
#SBATCH --partition=general
#SBATCH -o perm_%A_%a.o
#SBATCH -e perm_%A_%a.e

module load r/4.4.0-gfbf-2023a

Rscript - <<EOF

i <- as.numeric(Sys.getenv("SLURM_ARRAY_TASK_ID"))
set.seed(i)

env_mat <- read.csv("site_env_data_CentralOffshore.csv", header=TRUE)
env_mat <- as.data.frame(env_mat)
af_mat <- readRDS("af_mat.rds")

# Reorder env_mat to match af_mat
env_mat <- env_mat[match(rownames(af_mat), env_mat[, 1]), ]

# Shuffle temperature among sampling sites
env_mat\$temp_mean <- sample(env_mat\$temp_mean)

# Kendall correlation with permuted temperature
cor_test_wrapper <- function(p_vec, env_vector){
  correlation_result <- cor.test(p_vec, env_vector, method = "kendall", exact = F)
  return(c(correlation_result\$estimate, correlation_result\$p.val))
}

cor_results <- apply(as.matrix(af_mat), 2,
               function(x) cor_test_wrapper(x, env_mat\$temp_mean))

cor_results <- as.data.frame(t(cor_results))
names(cor_results) <- c("Kendall", "p_val")

# Convert to empirical p-values
cor_results\$emp_p <- rank(cor_results\$p_val) / nrow(cor_results)

# Add SNP IDs
snp_ids <- colnames(af_mat)
cor_results\$snp_id <- snp_ids

# Load SNP windows and MAF
snp_windows <- read.table("snp_windows.txt")
colnames(snp_windows) <- c("snp_id", "window_id")

maf_mat <- pmin(af_mat, 1 - af_mat)
avg_maf <- colMeans(maf_mat, na.rm = TRUE)

# Merge
wza_input <- merge(cor_results, snp_windows, by = "snp_id")
wza_input\$avg_maf <- avg_maf[match(wza_input\$snp_id, snp_ids)]

# Save permuted input
write.csv(wza_input, paste0("permutations_out/perm_input_", i, ".csv"), row.names=FALSE, quote=FALSE)

EOF

# Run WZA on permuted data
module load python/3.11.3-gcccore-12.3.0
module load scipy-bundle/2023.07-gfbf-2023a

python3 general_WZA_script.py \
  --correlations permutations_out/perm_input_${SLURM_ARRAY_TASK_ID}.csv \
  --summary_stat p_val \
  --window window_id \
  --MAF avg_maf \
  --output permutations_out/wza_output_perm_${SLURM_ARRAY_TASK_ID}.csv \
  --sep "," \
  --min_snps 3 \
  --resamples 100 \
  --sample_snps -1 \
  --verbose