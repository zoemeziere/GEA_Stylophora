# ============================================================
# 1. Libraries
# ============================================================
library(vegan)
library(dplyr)
library(purrr)

# ============================================================
# 2. Data
# ============================================================
metadata <- read.csv("WGSpisTaxon1_Metadata.csv")
env_data <- read.csv("env_data/env_Spis_ind_uncor_unscaled.csv", header = TRUE)

# Scale globally (so all populations are comparable)
env_scaled <- env_data
env_scaled[, 4:9] <- scale(env_scaled[, 4:9])
rownames(env_scaled) <- env_scaled$Samples.renames

# ============================================================
# 3. Define populations and RDA model directory
# ============================================================
populations <- c("Heron", "Lizard", "Moore", "OffshoreCentral", "Pelorus")
gen_dir <- "gen_data"
rda_dir <- "rda_models"
out_dir <- "rda_crossval_models"
dir.create(out_dir, showWarnings = FALSE)

# ============================================================
# 4. Helper function for one train–test pair
# ============================================================
predict_RDA_transfer <- function(train_pop, test_pop, env_scaled, metadata, rda_dir) {
  message("Training on ", train_pop, " → Testing on ", test_pop)

  # Load model and genotypes
  rda_train <- readRDS(file.path(rda_dir, paste0("rda_", train_pop, ".rds")))
  metadata_test <- metadata %>% filter(Population == test_pop)

  gen_test <- readRDS(file.path(gen_dir, paste0(test_pop, "_linked_imputed.rds")))
  gen_test <- gen_test[metadata_test$Samples.renames, , drop = FALSE]
  rownames(gen_test) <- metadata_test$Samples.renames

  # Prepare environmental data for test population
  env_test_scaled <- env_scaled[metadata_test$Samples.renames, 4:9]
  
  if (!all(rownames(gen_test) == rownames(env_test_scaled))) {
    stop("Row names of genotypes and environmental data do not match for ", test_pop)
  }

  # Predicted site scores for test population using trained model
  pred_scores <- as.data.frame(predict(rda_train, newdata = env_test_scaled, type = "lc", scaling = 2))
  pred_scores$Sample <- rownames(pred_scores)
  pred_scores$Population <- test_pop
  write.csv(pred_scores, file.path(out_dir, paste0("RDA_crossval_scores", test_pop ,".csv")))

  # Observed site scores from actual RDA model for test population
  rda_test <- readRDS(file.path(rda_dir, paste0("rda_", test_pop, ".rds")))
  obs_scores <- as.data.frame(scores(rda_test, display = "sites", scaling = 2))
  obs_scores$Sample <- rownames(obs_scores)
  obs_scores$Population <- test_pop

  # Combine observed vs predicted
  df_combined <- obs_scores %>%
    select(Sample, RDA1_obs = RDA1, RDA2_obs = RDA2) %>%
    left_join(
      pred_scores %>%
        select(Sample, Population, RDA1_pred = RDA1, RDA2_pred = RDA2),
      by = "Sample"
    ) %>%
    mutate(test_pop = test_pop)

  return(df_combined)
}

# ============================================================
# 5. Run all pairwise predictions
# ============================================================
pairwise_results <- list()

for (train_pop in populations) {
  for (test_pop in populations) {
    if (train_pop != test_pop) {
      df_combined <- predict_RDA_transfer(train_pop, test_pop, env_scaled, metadata, rda_dir)
      pairwise_results[[paste(train_pop, test_pop, sep = "_to_")]] <- df_combined
    }
  }
}

# ============================================================
# 6. Combine all results
# ============================================================
all_pairs_df <- bind_rows(pairwise_results, .id = "comparison")

# Save to file
write.csv(all_pairs_df, file.path(out_dir, "RDA_crossval_predictions.csv"))
