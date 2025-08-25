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

populations <- c("Heron", "OffshoreCentral", "Pelorus", "Moore", "Lizard")
SpisTaxon1_metadata <- read.csv("WGSpisTaxon1_Metadata.csv")
X <- read.csv("env_data/env_Spis_ind_uncor_unscaled.csv", header = TRUE)

# Loop through each population
for (pop in populations) {

  # Load the appropriate genotype and environmental data for the current population
  gen_pop <- readRDS(paste0("gen_data/", pop, "_linked_imputed.rds"))
  metadata_pop <- SpisTaxon1_metadata[SpisTaxon1_metadata$Population == pop, ]
  env_pop <- X[X$'Samples.renames' %in% metadata_pop$'Samples.renames', ]
  env_pop <- env_pop[match(rownames(gen_pop), env_pop$'Samples.renames'), ]

  # Pre-fit RDA on full dataset to determine max number of constrained axes
  rda_full <- rda(gen_pop ~ ., env_pop[, 4:9], scale=TRUE)
  num_axes <- ncol(rda_full$CCA$u)  # maximum number of constrained axes

  # Initialize a matrix to store the final predictions for the current population
  final_predictions <- matrix(NA, nrow = nrow(gen_pop), ncol = num_axes)  # Adjust ncol if more axes are used

  # Perform Leave-One-Out Cross-Validation (LOO-CV) for the current population
  for (i in 1:nrow(gen_pop)) {
    # Leave out one sample (train on the rest)
    train_indices <- setdiff(1:nrow(gen_pop), i)
    test_indices <- i

    gen_train <- gen_pop[train_indices, ]
    gen_test <- gen_pop[test_indices, ]

    env_train <- env_pop[train_indices, ]
    env_test <- env_pop[test_indices, ]

    # Train the RDA model on the training set
    rda_model <- rda(gen_train ~ ., env_train[, 4:9], scale=TRUE)

    # Make prediction for the left-out sample
    pred_test <- predict(rda_model, newdata = env_test[, 4:9], type = "lc")
    if (!is.matrix(pred_test)) pred_test <- matrix(pred_test, nrow = 1)

    # Store the prediction for the test sample in the matrix
    final_predictions[test_indices, ] <- pred_test
  }

  # Save the final predictions for this population
  saveRDS(final_predictions, paste0("pred_models/final_predictions_", pop, "_v2.rds"))
}

EOF
