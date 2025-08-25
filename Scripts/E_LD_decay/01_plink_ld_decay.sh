#!/bin/bash --login
#SBATCH --job-name="ld"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=500G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=24:00:00         # walltime
#SBATCH --account=a_riginos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o ld_%A.o         # standard output
#SBATCH -e ld_%A.e             # standard error

#module load anaconda3/2022.05
#source $EBROOTANACONDA3/etc/profile.d/conda.sh
#conda activate plink

#plink --file /scratch/project_mnt/S0078/WGS_Stylophora_Taxon1/filtering_vcftools/02_basic_filtering/Spis_noreplicates_badsamples_filtered_linked \
#	 --r2 --ld-window 10 --ld-window-kb 50000 --ld-window-r2 0 --out Spis_noreplicates_badsamples_filtered_linked --allow-extra-chr

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(data.table)
library(ggplot2)

data <- fread("Spis_noreplicates_badsamples_filtered_linked.ld")

data$distance <- abs(data$BP_A - data$BP_B)
data_50k <- data[data$distance < 50000,]

data_50k$distance <- cut(data_50k$distance, breaks=seq(from=min(data_50k$distance)-1,to=max(data_50k$distance)+1,by=1000))

pdf("ld_decay_smooth.pdf")

ggplot(data_50k, aes(x = distance, y = R2)) +
  geom_smooth(method = "loess", span = 0.3, color = "black", size = 1) + 
  labs(x = "Distance (bp)", y = "LD (r²)") +
  theme_minimal()

dev.off()

EOF
