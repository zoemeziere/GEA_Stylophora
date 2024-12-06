#!/bin/bash --login
#SBATCH --job-name="wza"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4		# number of cores per job
#SBATCH --mem=100G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=48:00:00		# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o wza_%A.o         # standard output
#SBATCH -e wza_%A.e	        # standard error

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(data.table)
library(dplyr)

cor_results <- readRDS("cor_results.rds")
site_freq <- readRDS("site_allele_frqs.rds")

# Build up p_mat and q_mat
p_mat <- matrix(nrow=nrow(site_freq[[1]]),ncol=length(site_freq))
q_mat <- p_mat
for(i in 1:ncol(p_mat)){
  p_mat[,i] <- site_freq[[i]]$'ref_freq'
  q_mat[,i] <- site_freq[[i]]$'alt_freq'
}

# And calculate pbar-qbar
pbar_qbar <- data.table(snp_id=paste0(site_freq[[1]]$'chr',":",site_freq[[1]]$'bp'),
                        pbar_qbar = rowMeans(p_mat,na.rm = T) * rowMeans(q_mat,na.rm = T))

# Add pbar-qbar
cor_results$'snp_id' <- rownames(cor_results)
cor_all <- merge(cor_results,pbar_qbar,by="snp_id")

# Filter away SNPs with NA pvals, or pvals=1
cor_all <- cor_all[!(is.na(cor_all$'p_val')),]

# Caclaulate empirical and z score
cor_all$'empirical_p' <- rank(cor_all$'p_val')/length(cor_all$'p_val')
cor_all$'z_score' <- qnorm(cor_all$'empirical_p', lower.tail = F)

# Order SNPs
#x <- sapply(cor_all$'snp_id', function(x) strsplit(x, ":")[[1]], USE.NAMES=FALSE)
#cor_all$'scaffold' <- x[1,]
#cor_all$'position' <- x[2,]

#cor_all$'position' <- as.numeric(cor_all$'position')
#cor_all <- cor_all[order(cor_all$'scaffold', cor_all$'position'), ]

# Get windows
#window_size <- 10000
#cor_all$'win_id' <- NA
#current_window_start <- 0
#window_id <- 1

#for(i in 1:nrow(cor_all)) {
  # Check if current SNP is in the current window
#  if(cor_all$'position'[i] >= current_window_start + window_size) {
    # Move to the next window
#    current_window_start <- cor_all$'position'[i]
#    window_id <- window_id + 1
#  }
  # Assign window id
#  cor_all$'win_id'[i] <- window_id
#}

# Get window ID column

windows_data <- read.table("snp_windows.txt", header = TRUE, stringsAsFactors = FALSE)
cor_all <- merge(cor_all, windows_data, by = "snp_id", all.x = TRUE)

# Calculate the numerator of the Weighted-Z score
weiZ_num <- tapply(cor_all$'pbar_qbar' * cor_all$'z_score', cor_all$'win_id', sum)

# Calculate the denominator of the Weighted-Z score
weiZ_den <- sqrt(tapply(cor_all$'pbar_qbar'^2, cor_all$'win_id', sum))

# Calculate WZA
WZA <- weiZ_num/weiZ_den

# Bring all in one table
#pos <- tapply(cor_all$'position', cor_all$'win_id', mean)

WZA_df <- data.frame(win_id = names(WZA), WZA = WZA)

saveRDS(WZA_df, "WZA_df.rds")

EOF
