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
OUTPUT_FILE="/scratch/project_mnt/S0078/WGS_Stylophora_Taxon1/correlation_coefficients/results/correlation_results.csv"		 # Output file for results

# Run the R script
Rscript - <<EOF

# Function to install missing packages
install_if_missing <- function(packages) {
  missing <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(missing)) install.packages(missing, repos = "http://cran.us.r-project.org") }

# Specify the required packages
required_packages <- c("vcfR", "foreach", "doParallel")

# Install missing packages
install_if_missing(required_packages)

# Load necessary libraries
library(vcfR)
library(foreach)
library(doParallel)
cat("Packages checked and installed.\n")
flush.console()

# Set number of cores for parallel processing
numCores <- as.integer(Sys.getenv('SLURM_CPUS_ON_NODE', '1')) # Get number of cores from the SLURM job

# Load the VCF file and extract genotype data
vcf <- read.vcfR("$VCF_FILE")
cat("VCF loaded and genotype data extracted.\n")
flush.console()

geno <- extract.gt(vcf, element = "GT", as.numeric = TRUE)
geno <- t(geno)
cat("Genotype matrix transposed.\n")
flush.console()

# Load the environmental data
env_data <- read.csv("$ENV_FILE")

# Initialize parallel processing
cl <- makeCluster(numCores)
registerDoParallel(cl)

# Function to calculate both correlation and p-value
get_cor_pvalue <- function(x, y) {
  correlation_result <- cor.test(x, y, method = "kendall", exact = F)
  return(c(correlation_result$estimate, correlation_result$'p.val')) }

# Calculate correlation coefficients and p-values for each SNP with the environmental variable
cor_results <- foreach(i = 1:ncol(geno), .combine = 'rbind') %dopar% {
  get_cor_pvalue(geno[, i], env_data[,12]) }
cat("Correlation calculations complete.\n")
flush.console()

# Stop the cluster after the calculations
stopCluster(cl)

# Save results to a CSV file
cor_results <- as.data.frame(cor_results)
names(cor_results) <- c("Kendall", "p_val")
write.csv(cor_results, file = "$OUTPUT_FILE")

EOF

echo "Correlation calculation completed. Results saved to $OUTPUT_FILE"
