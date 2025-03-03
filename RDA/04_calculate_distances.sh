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

### Script to calculate Mahalanobis distances for all individuals for each pair of predictive model and true model

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(vegan)

populations <- c("Heron", "OffshoreCentral", "Pelorus", "Moore", "Lizard")

distance_results <- data.frame(TrainPop = character(),
                               TestPop = character(),
                               Individual = integer(),
                               Distance = numeric(),
                               stringsAsFactors = FALSE)

for (train_pop in populations) {
  for (test_pop in populations) {
    if (train_pop != test_pop) {

      # Load the pre-trained RDA model for the test population
      rda_test_model <- readRDS(paste0("rda_models/rda_", test_pop, ".rds"))

      # Load the observed RDA scores for the test population
      observed_test <- scores(rda_test_model, display = "sites")

      # Load the predictive model (predicted RD scores for the test population)
      pred_test <- readRDS(paste0("pred_models/pred_", test_pop, "_from_", train_pop, ".rds"))

      # Calculate the covariance matrix of the observed RD scores (across all individuals and all axes)
      cov_matrix <- cov(observed_test)

      # Calculate the mean of the observed data
      observed_mean <- colMeans(observed_test)

      # Loop over all individuals to calculate Mahalanobis distance
      for (i in 1:nrow(observed_test)) {
        # Extract the observed and predicted RD scores for individual i
        observed_individual <- observed_test[i, , drop = FALSE]
        predicted_individual <- pred_test[i, 1:2, drop = FALSE]

        # Calculate the Mahalanobis distance
        distance <- mahalanobis(predicted_individual, observed_mean, cov_matrix)

        # Store the result
        distance_results <- rbind(distance_results, data.frame(TrainPop = train_pop, 
                                                              TestPop = test_pop,
                                                              Individual = i, 
                                                              Distance = distance))
      }
    }
  }
}

saveRDS(distance_results, "distance_results.rds")

EOF
