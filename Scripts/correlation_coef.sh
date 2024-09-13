#!/bin/bash --login

#SBATCH --job-name="correlation"      # Job name
#SBATCH --output=correlation_%A.o  # Log output (with job ID)
#SBATCH --error=correlation_%A.e    # Error log
#SBATCH --ntasks-per-node=1                          # Run on a single task
#SBATCH --cpus-per-task=1                  # Number of CPU cores per task
#SBATCH --mem=100G                           # Job memory request
#SBATCH --time=24:00:00                     # Time limit hrs:min:sec
#SBATCH --partition=general             # queue name
#SBATCH --account=a_riginos             # group account name
#SBATCH --nodes=1               # use 1 node

module load r/4.2.1-foss-2022a

VCF_FILE="/scratch/project_mnt/S0078/WGS_Stylophora_Taxon1/filtering_vcftools/04_populations/no_missing_data/Spis_ind_OffshoreCentral_nomissingdata.vcf"            # Path to VCF file
ENV_FILE="/scratch/project_mnt/S0078/WGS_Stylophora_Taxon1/correlation_coefficients/env_data/env_data_OffshoreCentral.csv"             # Path to environmental data CSV

# Run the R script
Rscript - <<EOF

library(vcfR)
library(foreach)

# Make a little wrapper function for cor.test to return the summary stat and the p-value as a vector
cor_test_wrapper <- function(p_vec, env_vector) {
  # Check if either vector has zero variance
  if (sd(p_vec) == 0 || sd(env_vector) == 0) {
    return(c(NA, NA))  # Return NA for both estimate and p-value
  } else {
    # Perform the correlation test
    correlation_result <- cor.test(p_vec, env_vector, method = "kendall", exact = FALSE)
    return(c(correlation_result$estimate, correlation_result$p.value))
  }}

# VCF to dataframe
vcf <- read.vcfR("$VCF_FILE")
geno <- extract.gt(vcf, element = "GT", as.numeric = TRUE)

# Load the environmental data
env_data <- read.csv("$ENV_FILE", header=F)

# Use the apply function to use the wrapper function on each line of the DF - this step takes a while...
cor_results <- apply(geno, 1, function(x) cor_test_wrapper(x, env_data[,12]))

# transpose the result and store as a dataframe
cor_results <- as.data.frame(t(cor_results))

# save file
write.csv(cor_results, "/scratch/project_mnt/S0078/WGS_Stylophora_Taxon1/correlation_coefficients/cor_results")

EOF
