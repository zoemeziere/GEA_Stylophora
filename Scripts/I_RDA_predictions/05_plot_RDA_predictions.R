library(vegan)
library(ggplot2)

populations_test <- c("Heron", "OffshoreCentral", "Pelorus", "Moore", "Lizard")
populations_test <- c("Heron", "OffshoreCentral", "Pelorus", "Moore", "Lizard", "global")

for (test_pop in populations_test) {

  # Create a directory for the test population if it doesn't already exist
  test_pop_dir <- paste0("pred_plots/", test_pop)
  if (!dir.exists(test_pop_dir)) {
    dir.create(test_pop_dir)
  }

  # Loop through each train population (excluding the test population)
  for (train_pop in populations_train) {

      # Load the true  RDA model for that population
      rda_model <- readRDS(paste0("rda_models/rda_", test_pop, ".rds"))

      # Load the predictive model for that population
      pred_model <- readRDS(paste0("pred_models/pred_", test_pop, "_from_", train_pop, ".rds"))

      # Create PDF for plotting
      pdf(file = paste0(test_pop_dir, "/", test_pop, "_trained_on_", train_pop, ".pdf"))

      # Plotting genotypes position under two models
      plot(pred_model[, 1], pred_model[, 2], 
            main = paste("True RDA for", test_pop, "vs predicted RDA for", test_pop, "trained using", train_pop),
            xlab = "RDA1", ylab = "RDA2", col = "red", pch = 19,
            xlim = c(min(pred_model[, 1], rda_model$CCA$u[, 1]), max(pred_model[, 1], rda_model$CCA$u[, 1])), 
            ylim =c(min(pred_model[, 2], rda_model$CCA$u[, 2]), max(pred_model[, 2], rda_model$CCA$u[, 2])))
      points(rda_model$CCA$u[, 1], rda_model$CCA$u[, 2], col = "blue", pch = 19)

      legend("topright", legend = c("Predicted RDA Model", "True RDA Model"),
               col = c("red", "blue"), pch = 19)

      dev.off()
    }
  }
}

EOF
