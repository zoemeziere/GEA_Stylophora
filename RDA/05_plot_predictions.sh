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

### Script to plot true RDA models and predictive models

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(vegan)
library(ggplot2)

populations <- c("Heron", "OffshoreCentral", "Pelorus", "Moore", "Lizard")

for (test_pop in populations) {

  # Create a directory for the test population if it doesn't already exist
  test_pop_dir <- paste0("pred_plots/", test_pop)
  if (!dir.exists(test_pop_dir)) {
    dir.create(test_pop_dir)
  }

  # Loop through each train population (excluding the test population)
  for (train_pop in populations) {
    if (train_pop != test_pop) {

      # Load the true  RDA model for that population
      rda_model <- readRDS(paste0("rda_models/rda_", test_pop, ".rds"))

      # Load the predictive model for that population
      pred_model <- readRDS(paste0("pred_models/pred_", test_pop, "_from_", train_pop, ".rds"))

      # Create PDF for plotting
      pdf(file = paste0(test_pop_dir, "/", test_pop, "_trained_on_", train_pop, ".pdf"))

      # Plotting genotypes position under two models
      plot(rda_model$CCA$u[, 1], rda_model$CCA$u[, 2],
           main = paste("True RDA for", test_pop, "vs predicted RDA for", test_pop, "trained using", train_pop),
           xlab = "RDA1", ylab = "RDA2",
           col = "blue", pch = 19)

      points(pred_model[, 1], pred_model[, 2], col = "red", pch = 19)

      legend("topright", legend = c("True RDA Model", "Predicted RDA Model"),
               col = c("blue", "red"), pch = 19)

      dev.off()
    }
  }
}

EOF
