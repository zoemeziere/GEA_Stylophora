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

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(RDAforest)
library(rnaturalearth)
library(rnaturalearthdata)
library(terra)
library(viridis)
library(adegenet)
library(vcfR)

gen <- read.vcfR("Spis_noreplicates_badsamples_filtered_linked.vcf")

str(gen)

gen.gt <- extract.gt(gen)
gen.gt.t <- t(gen.gt)
sum(is.na(gen.gt.t)) #59466012

gen.gt.t[gen.gt.t %in% c("0|0", "0/0")] <- 0
gen.gt.t[gen.gt.t %in% c("0|1", "0/1")] <- 1
gen.gt.t[gen.gt.t %in% c("1|1", "1/1")] <- 2

gen.imp <- apply(gen.gt.t, 2, function(x) replace(x, is.na(x), as.numeric(names(which.max(table(x))))))
sum(is.na(gen.imp)) #0
class(gen.imp) <- "numeric"

saveRDS(gen.imp, "gen.imp.rds")
