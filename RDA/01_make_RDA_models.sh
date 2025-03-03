#!/bin/bash --login
#SBATCH --job-name="RDA"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=100G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=2:00:00         # walltime
#SBATCH --account=a_riginos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o rdaforest_%A.o         # standard output
#SBATCH -e rdaforest_%A.e             # standard error

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(vegan)
library(dplyr)

populations <- c("Heron", "OffshoreCentral", "Pelorus", "Moore", "Lizard")

SpisTaxon1_metadata <- read.csv("WGSpisTaxon1_Metadata.csv")
X <- read.csv("env_data/env_Spis_ind_uncor_unscaled.csv", header = TRUE)

for (pop in populations) {
   rds_file <- paste0("gen_data/", pop, "_linked_imputed.rds")
   gen_pop <- readRDS(rds_file)
   pop_data <- SpisTaxon1_metadata[SpisTaxon1_metadata$Population == pop, ]
   X <- cbind(X[,1:2], scale(X[,3:6]))
   env_pop <- X[X$'Samples.renames' %in% pop_data$'Samples.renames', ]
   env_pop <- env_pop[match(rownames(gen_pop), env_pop$'Samples.renames'), ]
   rda_pop <- rda(gen_pop ~ ., data=env_pop[,3:6])
   saveRDS(rda_pop, paste0("rda_", pop, ".rds"))
}

EOF
