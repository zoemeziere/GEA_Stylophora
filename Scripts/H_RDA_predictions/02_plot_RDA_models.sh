#!/bin/bash --login
#SBATCH --job-name="RDA"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=100G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=1:00:00         # walltime
#SBATCH --account=a_riginos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o rdaforest_%A.o         # standard output
#SBATCH -e rdaforest_%A.e             # standard error

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(vegan)
library(dplyr)

populations <- c("Heron", "OffshoreCentral", "Pelorus", "Moore", "Lizard")

for (pop in populations) {
   rda_model <- readRDS(paste0("rda_models/rda_", pop, ".rds"))
   pdf(paste0("rda_", pop, "_ind.pdf"))
   plot(rda_model, type="n", scaling=3)
   points(rda_model, display="species", pch=20, cex=2, col="gray32", scaling=3)
   points(rda_model, display="sites", pch=21, cex=2, col="red", scaling=3)
   text(rda_model, display="bp", col="black", cex=1, scaling=3)
   dev.off()
}

EOF
