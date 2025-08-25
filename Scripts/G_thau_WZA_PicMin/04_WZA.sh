module load r/4.2.1-foss-2022a

cor_results<-readRDS("cor_results.rds")
af_mat<-readRDS("af_mat.rds")
snp_windows<-read.table("snp_windows.txt")

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
#    Assuming snp_windows has columns: snp_id, window_id
colnames(snp_windows) <- c("snp_id", "window_id")

# 5. Merge all data
wza_input <- merge(cor_results, snp_windows, by = "snp_id")
wza_input$avg_maf <- avg_maf[match(wza_input$snp_id, snp_ids)]

# 6. Save to file
write.csv(wza_input, "wza_input_CentralOffshore.csv", row.names = FALSE, quote = FALSE)

### 2- CALCULATE WZA ####

python3 general_WZA_script.py --correlations wza_input_CentralOffshore.csv \
	--summary_stat p_val \
	--window window_id \
	--MAF avg_maf \
	--output wza_output_CentralOffshore.csv \
	--sep "," \
	--large_i_small_p
