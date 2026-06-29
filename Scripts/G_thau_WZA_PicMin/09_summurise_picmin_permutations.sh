#!/bin/bash --login
#SBATCH --job-name="permu_plot"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=500G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=10:00:00         # walltime
#SBATCH --account=a_senv_mbos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o picmin_perm_plot%A.o         # standard output
#SBATCH -e picmin_perm_plot%A.e             # standard error

module load r/4.4.0-gfbf-2023a

Rscript - <<EOF

# Set path to the folder containing permutation result files
result_files <- list.files("permutation_results", pattern = "^permuted_results_.*\\.rds$", full.names = TRUE)

# Initialize vector to hold the number of significant windows
sig_counts <- numeric(length(result_files))
all_q_vals <- list()

for (i in seq_along(result_files)) {
  res <- readRDS(result_files[i])
  
  # Ensure pooled_q exists
  if (!"pooled_q" %in% colnames(res)) next
  
  # Store pooled_q values
  all_q_vals[[i]] <- res$pooled_q
  
  # Count significant windows
  sig_counts[i] <- sum(res$pooled_q < 0.5, na.rm = TRUE)
}

# Convert all_q_vals to one vector
all_q_vector <- unlist(all_q_vals)

# Plot histograms 
pdf("picmin_permutations.pdf")

hist(all_q_vector,
     breaks = 50,
     col = "skyblue",
     main = "Distribution of pooled q-values across permutations",
     xlab = "pooled_q")

hist(sig_counts,
     breaks = 30,
     col = "salmon",
     main = "Number of windows with pooled_q < 0.5 per permutation",
     xlab = "Significant windows per permutation")

dev.off()

# Median number of significant windows
cat("Median number of significant windows (pooled_q < 0.5) under null model:", median(sig_counts), "\n")

# Save summary statistics
summary_df <- data.frame(
  permutation = seq_along(sig_counts),
  num_sig_windows = sig_counts
)

write.csv(summary_df, "picmin_permutations_summary.csv", row.names = FALSE)

EOF