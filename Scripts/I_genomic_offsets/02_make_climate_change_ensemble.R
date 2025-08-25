#!/bin/bash --login
#SBATCH --job-name="RDA"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=900G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=2:00:00         # walltime
#SBATCH --account=a_riginos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o ensemble_%A.o         # standard output
#SBATCH -e ensemble_%A.e             # standard error


module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(dplyr)
library(readr)
library(data.table)
library(tibble)

## SSP1.26

csv_files <- list.files("../CMIP-6", pattern = "126per", full.names = TRUE)
models_data <- lapply(csv_files, fread)

preprocess_data <- function(df, model_index) {
  df <- as.data.frame(df)
  reefsUNIQUE_ID <- df$reefsUNIQUE_ID
  rownames(df) <- reefsUNIQUE_ID
  df <- df[, -1]
  return(df)
}

models_data <- lapply(seq_along(models_data), function(i) {
  df <- models_data[[i]]
  return(preprocess_data(df, i))
})

# Extract common years and locations across all models
common_years <- Reduce(intersect, lapply(models_data, function(df) colnames(df)))  # Exclude the reefsUNIQUE_ID column
common_locations <- Reduce(intersect, lapply(models_data, function(df) rownames(df)))  # Extract common locations from row names

# Align the data for all models (only the common locations and years)
models_data_aligned <- lapply(models_data, function(df) {
  df <- df[rownames(df) %in% common_locations, common_years, drop = FALSE]  # Keep only common locations and years
  return(df)
})

# Creat ensemble
ensemble_sum <- Reduce("+", models_data_aligned)
ensemble_df <- ensemble_sum / length(models_data_aligned)

ensemble_df$reefsUNIQUE_ID <- rownames(ensemble_df)

#Save the ensemble result to a CSV file
write.csv(ensemble_df, "ensemble_SSP126.csv", row.names = FALSE)


EOF
