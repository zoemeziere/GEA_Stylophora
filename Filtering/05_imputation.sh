#!/bin/bash --login
#SBATCH --job-name="RDAforest"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=50G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=02:00:00         # walltime
#SBATCH --account=a_riginos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o rdaforest_%A.o         # standard output
#SBATCH -e rdaforest_%A.e             # standard error

# Impute vcf using BEAGLE 4.1

module load java

java -jar beagle.r1399.jar gt=Spis_noreplicates_badsamples_filtered_linked.vcf out=beagle_Spis_filtered_linked

# Transform data into genotype matrix

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(vcfR)

gen <- read.vcfR("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/vcf_files/beagle4_Spis_filtered_linked_imp.vcf")

gen.gt <- extract.gt(gen)
gen.gt.t <- t(gen.gt)

gen.gt.t[gen.gt.t %in% c("0|0", "0/0")] <- 0
gen.gt.t[gen.gt.t %in% c("0|1", "0/1")] <- 1
gen.gt.t[gen.gt.t %in% c("1|1", "1/1")] <- 2

saveRDS(gen.gt.t, "SpisTaxon1_linked_imputed.rds")
