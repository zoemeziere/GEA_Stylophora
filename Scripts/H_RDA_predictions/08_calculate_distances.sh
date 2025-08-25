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

### Script to calculate Euclidean distances for all individuals for each pair of predictive model and true model

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(vegan)

populations_train <- c("Heron", "Pelorus", "Moore", "Lizard", "global", "OffshoreCentral")
populations_test <- c("Heron",  "Pelorus", "Moore", "Lizard", "OffshoreCentral")

distance_results <- data.frame(TrainPop = character(),
                               TestPop = character(),
                               Individual = integer(),
                               Distance = numeric(),
                               stringsAsFactors = FALSE)

for (train_pop in populations_train) {
  for (test_pop in populations_test) {

      # Load the observed (true) model
      rda_test_model <- readRDS(paste0("rda_models/rda_", test_pop, ".rds"))

      # Load the observed RDA scores for the test population
      observed_test <- scores(rda_test_model, display = "sites")

      # Load the predicted home and away model
      pred_model <- readRDS(paste0("pred_models/pred_", test_pop, "_from_", train_pop, ".rds"))

      # Loop over all individuals to calculate Euclidean distance
      for (i in 1:nrow(observed_test)) {
        # Extract the observed and predicted RD scores for individual i
        observed_individual <- observed_test[i, 1:2 , drop = FALSE]
        predicted_individual <- pred_model[i, 1:2, drop = FALSE]

        # Calculate the distance
        distance <- sqrt(sum((observed_individual - predicted_individual)^2))

        # Store the result
        distance_results <- rbind(distance_results, data.frame(TrainPop = train_pop, 
                                                              TestPop = test_pop,
                                                              Individual = i, 
                                                              Distance = distance))
    }
  }
}

saveRDS(distance_results, "distance_results.rds")

EOF
