#!/bin/bash --login
#SBATCH --job-name="wza"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=100G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=48:00:00         # walltime
#SBATCH --account=a_senv_mbos           # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o wza_%A.o         # standard output
#SBATCH -e wza_%A.e             # standard error

module load r/4.4.0-gfbf-2023a

# Run R

Rscript - <<EOF

cor_results<-readRDS("cor_results.rds")
af_mat<-readRDS("af_mat.rds")
snp_windows<-read.table("snp_windows_20kb.txt")

### 1- CALCULATE MAF ####

# 1. Get SNP IDs from af_mat
snp_ids <- colnames(af_mat)

# 2. Calculate average MAF across populations
#    MAF for each SNP in each pop = min(ref_freq, 1 - ref_freq)
maf_mat <- pmin(af_mat, 1 - af_mat)  # same dimensions as af_mat
avg_maf <- colMeans(maf_mat, na.rm = TRUE)

# 3. Prepare cor_results with SNP IDs
cor_results$snp_id <- snp_ids

# 4. Prepare snp_windows
colnames(snp_windows) <- c("snp_id", "window_id")

# 5. Merge all data
wza_input <- merge(cor_results, snp_windows, by = "snp_id")
wza_input$avg_maf <- avg_maf[match(wza_input$snp_id, snp_ids)]

# 6. Save to file
write.csv(wza_input, "wza_input_CentralOffshore.csv", row.names = FALSE, quote = FALSE)

EOF

### 2- CALCULATE WZA ####

module load python/3.11.3-gcccore-12.3.0
module load scipy-bundle/2023.07-gfbf-2023a

python3 general_WZA_script.py --correlations wza_input_CentralOffshore.csv \
        --summary_stat p_val \
        --window window_id \
        --MAF avg_maf \
        --output wza_output_CentralOffshore.csv \
        --sep "," \
        --min_snps 3 \
        --resamples 100 \
        --sample_snps -1 \
        --verbose