#!/bin/bash --login
#SBATCH --job-name="RDA"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=500G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=24:00:00         # walltime
#SBATCH --account=a_riginos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o rdaforest_%A.o         # standard output
#SBATCH -e rdaforest_%A.e             # standard error

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(vegan)
library(dplyr)
library(ggplot2)

SpisTaxon1_metadata <- read.csv("WGSpisTaxon1_Metadata.csv")
X <- read.csv("env_data_Spis_uncor.csv", header = TRUE)

populations <- unique(SpisTaxon1_metadata$Population)

rda_results <- list()

for(pop in populations) {
  rds_file <- paste0(pop, "_linked_imputed.rds")
  Y_pop <- readRDS(rds_file)
  pop_data <- SpisTaxon1_metadata %>% filter(Population == pop)
  X_pop <- X[X$Sample_names %in% pop_data$Samples.renames, ]
  rda_pop <- rda(Y_pop ~ ., data=X_pop[,-1], scale=T)
  rda_results[[pop]] <- rda_pop
}

saveRDS(rda_results[["Heron"]], "rda_Heron.rds")
saveRDS(rda_results[["LadyMusgrave"]], "rda_LadyMusgrave.rds")
saveRDS(rda_results[["OffshoreCentral"]], "rda_OffshoreCentral.rds")
saveRDS(rda_results[["Pelorus"]], "rda_Pelorus.rds")
saveRDS(rda_results[["Lizard"]], "rda_Lizard.rds")
saveRDS(rda_results[["Moore"]], "rda_Moore.rds"

rda_list <- list(
  rda_Heron = readRDS("rda_Heron.rds"),
  rda_LadyMusgrave = readRDS("rda_LadyMusgrave.rds"),
  rda_OffshoreCentral = readRDS("rda_OffshoreCentral.rds"),
  rda_Pelorus = readRDS("rda_Pelorus.rds"),
  rda_Moore = readRDS("rda_Moore.rds"),
  rda_Lizard = readRDS("rda_Lizard.rds"))

populations <- c("Heron", "LadyMusgrave", "OffshoreCentral", "Pelorus", "Moore", "Lizard")
SpisTaxon1_metadata <- read.csv("WGSpisTaxon1_Metadata.csv")

pdf("rda_populations.pdf")

for(pop in populations) {
  rda_model <- rda_list[[paste0("rda_", pop)]]
  metadata <- SpisTaxon1_metadata[SpisTaxon1_metadata$Population == pop, ]
  site_colors <- rainbow(length(unique(metadata$EcoLocationID_short)))
  names(site_colors) <- unique(metadata$EcoLocationID_short)
  bg_colors <- site_colors[metadata$EcoLocationID_short]
  plot(rda_model, type="n", scaling=3)
  points(rda_model, display="species", pch=20, cex=2, col="gray32", scaling=3)
  points(rda_model, display="sites", pch=21, cex=2, col="gray32", scaling=3, bg=bg_colors)
  text(rda_model, display="bp", col="black", cex=1, scaling=3)
  title(main = paste("plot_RDA_", pop))
}

dev.off()

EOF
