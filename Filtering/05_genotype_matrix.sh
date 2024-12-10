#!/bin/bash --login
#SBATCH --job-name="genotype_matrix"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=50G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=02:00:00         # walltime
#SBATCH --account=a_riginos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o rgenotype_matrix_%A.o         # standard output
#SBATCH -e genotype_matrix_%A.e             # standard error

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(vcfR)

gen <- read.vcfR("Spis_noreplicates_badsamples_filtered_linked.vcf")

gen.gt <- extract.gt(gen)
gen.gt.t <- t(gen.gt)

gen.gt.t[gen.gt.t %in% c("0/0")] <- 0
gen.gt.t[gen.gt.t %in% c("0/1")] <- 1
gen.gt.t[gen.gt.t %in% c("1/0")] <- 1
gen.gt.t[gen.gt.t %in% c("1/1")] <- 2

class(gen.gt.t) <- "numeric"

saveRDS(gen.gt.t, "SpisTaxon1_linked.rds")

EOF
