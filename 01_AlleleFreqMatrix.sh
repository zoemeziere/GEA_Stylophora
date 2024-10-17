#!/bin/bash --login
#SBATCH --job-name="allfreq"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4		# number of cores per job
#SBATCH --mem=10G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=1:00:00		# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o allfreq_%A.o         # standard output
#SBATCH -e allfreq_%A.e	        # standard error

#####
# Need to first create files with individuals for each site (e.g., ind_ONMO_FR1S), all stored in directory new indFreq
####

module load vcftools

# Create individual VCF files
#for indList in  indFreq/ind_*;
#do
#    vcftools --vcf Spis_ind_CentralOffshore_filtered.vcf \
#             --keep $indList \
#             --recode \
#             --stdout | gzip -c > ${indList}.vcf.gz
#done

# Calculate allele frequencies for each gzipped VCF
#for vcf in indFreq/ind*.vcf.gz;
#do
#    vcftools --gzvcf $vcf \
#             --freq \
#             --out ${vcf%.vcf.gz}
#done

# Move .freq files to main directory

#mv indFreq/*.frq /

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(foreach)
library(parallel)
library(doParallel)
library(data.table)

cl <- makeCluster(12, type="FORK")
registerDoParallel(cl)

Metadata <- read.csv("CentralOffshore_Metadata.csv")

site_freqs <- foreach(site_pop = unique(Metadata$'EcoLocationID_short')) %dopar% {
      freq_res <- suppressMessages(data.frame(fread(paste0("ind_",site_pop,".frq"))))
      colnames(freq_res) <- c("chr","bp","allele_N","allele_count","ref_freq","alt_freq")

# Reformat frequencies
      freq_res$'ref_freq' <- gsub("[^0-9.-]", "", freq_res$'ref_freq')
      freq_res$'alt_freq' <- gsub("[^0-9.-]", "", freq_res$'alt_freq')

# Format for output
      freq_out <- data.frame(chr=freq_res$'chr',
                             bp=freq_res$'bp',
                             ref_freq=as.numeric(freq_res$'ref_freq'),
                             alt_freq=as.numeric(freq_res$'alt_freq'),
                             pop=site_pop)
return(freq_out)
}

# Save this list of frequencies to an RDS
saveRDS(site_freqs, "site_allele_frqs.rds")

# Build the AF matrix
af_mat <- matrix(ncol=nrow(site_freqs[[1]]),nrow=length(site_freqs))

for(i in 1:nrow(af_mat)){
  af_mat[i,] <- site_freqs[[i]][,"ref_freq"]
}

class(af_mat) <- "numeric"
rownames(af_mat) <- unique(Metadata$'EcoLocationID_short')
colnames(af_mat) <- paste0(site_freqs[[1]]$'chr',":",site_freqs[[1]]$'bp')

saveRDS(af_mat, "af_mat.rds")

EOF

mv ind_* indFreq
