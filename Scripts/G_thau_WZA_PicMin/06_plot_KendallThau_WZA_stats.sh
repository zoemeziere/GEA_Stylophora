#!/bin/bash --login
#SBATCH --job-name=wza_per_sum
#SBATCH --job-name="wza_per_sum"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=50G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=0:30:00         # walltime
#SBATCH --account=a_senv_mbos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o wza_per_sum_%A.o         # standard output
#SBATCH -e wza_per_sum_%A.e             # standard error

module load r/4.4.0-gfbf-2023a

Rscript - <<'EOF'

library(dplyr)
library(ggplot2)

# Load Kendall tau results
kendall <- readRDS("cor_results.rds")

# Load observed WZA
obs <- read.csv("wza_output_CentralOffshore.csv")

# Load all permutations
perm_files <- list.files(path="permutations_out", pattern="wza_output_perm_.*\\.csv$", full.names=TRUE)
perm_list <- lapply(perm_files, read.csv)
perm <- bind_rows(perm_list)

pdf("Central_diagnostics.pdf")

# 1. Kendall tau correlation coefficients
ggplot(kendall, aes(x = Kendall)) +
  geom_histogram(bins = 50, fill = "skyblue", color = "black") +
  theme_gray() +
  labs(x = "Kendall tau correlation coefficient", y = "Count",
       title = "Distribution of Kendall tau correlation coefficients")

# 2. Kendall tau raw p-values
ggplot(kendall, aes(x = p_val)) +
  geom_histogram(bins = 50, fill = "skyblue", color = "black") +
  theme_gray() +
  labs(x = "Raw p-value", y = "Count",
       title = "Distribution of Kendall tau raw p-values")

# 5. WZA Z-scores
ggplot(obs, aes(x = Z)) +
  geom_histogram(bins = 50, fill = "skyblue", color = "black") +
  theme_gray() +
  labs(x = "WZA Z-score", y = "Count",
       title = "Distribution of WZA Z-scores")

# 6. WZA raw p-values
ggplot(obs, aes(x = Z_pVal)) +
  geom_histogram(bins = 50, fill = "skyblue", color = "black") +
  theme_gray() +
  labs(x = "WZA raw p-value", y = "Count",
       title = "Distribution of WZA raw p-values")

# 8. Observed vs permuted WZA Z-score distributions
ggplot() +
  geom_density(data = perm, aes(x = Z, fill = "Permuted"), alpha = 0.5) +
  geom_density(data = obs, aes(x = Z, fill = "Observed"), alpha = 0.5) +
  scale_fill_manual(values = c("Permuted" = "grey70", "Observed" = "skyblue")) +
  theme_gray() +
  labs(x = "Z-score", y = "Density",
       title = "Observed vs. Permuted WZA Z-scores",
       fill = "Distribution") +
  theme(legend.position = "top")

dev.off()

EOF