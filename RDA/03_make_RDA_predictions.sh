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

### Script to make predictive models using RDA model from training population and environmental data from test population

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(vegan)
library(dplyr)

populations <- c("Heron", "OffshoreCentral", "Pelorus", "Moore", "Lizard")

#gen_Heron <- readRDS("gen_data/Heron_linked_imputed.rds")
#gen_Pelorus <- readRDS("gen_data/Pelorus_linked_imputed.rds")
#gen_OffshoreCentral <- readRDS("gen_data/OffshoreCentral_linked_imputed.rds")
#gen_Moore <- readRDS("gen_data/Moore_linked_imputed.rds")
#gen_Lizard <- readRDS("gen_data/Lizard_linked_imputed.rds")

SpisTaxon1_metadata <- read.csv("WGSpisTaxon1_Metadata.csv")
X <- read.csv("env_data/env_Spis_ind_uncor_unscaled.csv", header = TRUE)

for (train_pop in populations) {
  for (test_pop in populations) {
    if (train_pop != test_pop) {

      # Load the pre-trained RDA model for the training population
      rda_model <- readRDS(paste0("rda_models/rda_", train_pop, ".rds"))

      # Load genomics data
      gen_test <- readRDS(paste0("gen_data/", test_pop, "_linked_imputed.rds"))
      gen_pop <- readRDS(paste0("gen_data/", train_pop, "_linked_imputed.rds"))

      # Prepare the test population's environmental data
      X <- cbind(X[,1:2], scale(X[,3:6]))
      metadata_test <- SpisTaxon1_metadata[SpisTaxon1_metadata$Population == test_pop, ]
      env_test <- X[X$'Samples.renames' %in% metadata_test$'Samples.renames', ]
      env_test <- env_test[match(rownames(gen_test), env_test$'Samples.renames'), ]

      # Make predictions for the test population using the RDA model trained on the train population
      pred_test <- predict(rda_model, newdata = env_test[,3:6], type = "lc")

      # Save predictive models
      saveRDS(pred_test, paste0("pred_models/pred_", test_pop, "_from_", train_pop, ".rds"))

    }
  }
}


EOF
