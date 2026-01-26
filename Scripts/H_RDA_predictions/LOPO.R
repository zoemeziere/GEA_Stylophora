# ============================================================
# 1. Libraries
# ============================================================
library(vegan)
library(dplyr)
library(purrr)
library(readr)

# ============================================================
# 2. Data
# ============================================================
metadata <- read.csv("WGSpisTaxon1_Metadata.csv")
env_data <- read.csv("env_data/env_Spis_ind_uncor_unscaled.csv", header = TRUE)

# Scale environmental variables globally (so all populations are comparable)
env_scaled <- env_data
env_scaled[, 4:9] <- scale(env_scaled[, 4:9])
rownames(env_scaled) <- env_scaled$Samples.renames

# ============================================================
# 3. Populations and directories
# ============================================================
populations <- c("Heron", "Lizard", "Moore", "OffshoreCentral", "Pelorus")
gen_dir <- "gen_data"
rda_dir <- "rda_models"
out_dir <- "rda_lopo_models"
dir.create(out_dir, showWarnings = FALSE)

# ============================================================
# 4. Helper function for LOPO RDA
# ============================================================
run_lopo_rda <- function(test_pop, populations, metadata, env_scaled, gen_dir, rda_dir) {
  message("=== Testing on ", test_pop, " (training on all others) ===")

  # Define training populations
  train_pops <- setdiff(populations, test_pop)

  # Combine genotype data for training
  gen_train_list <- lapply(train_pops, function(pop) {
    df <- readRDS(file.path(gen_dir, paste0(pop, "_linked_imputed.rds")))
    metadata_pop <- metadata %>% filter(Population == pop)
    rownames(df) <- metadata_pop$Samples.renames
    df
  })
  gen_train <- do.call(rbind, gen_train_list)

  # Prepare training environmental data
  metadata_train <- metadata %>% filter(Population %in% train_pops)
  env_train <- env_scaled[metadata_train$Samples.renames, 4:9]

  # Fit model model on training data
  rda_train <- rda(gen_train ~ ., data = as.data.frame(env_train), scale = FALSE)

  # Save RDA model
  saveRDS(rda_train, file.path(out_dir, paste0("rda_LOPO_excluding_", test_pop, ".rds")))

  # ------------------------------------------------------------
  # Predict for held-out (test) population
  # ------------------------------------------------------------
  gen_test <- readRDS(file.path(gen_dir, paste0(test_pop, "_linked_imputed.rds")))
  metadata_test <- metadata %>% filter(Population == test_pop)

  gen_test <- gen_test[metadata_test$Samples.renames, , drop = FALSE]
  rownames(gen_test) <- metadata_test$Samples.renames

  # Prepare environmental data for test population
  env_test_scaled <- env_scaled[metadata_test$Samples.renames, 4:9]

  if (!all(rownames(gen_test) == rownames(env_test_scaled))) {
    stop("Row names of genotypes and environmental data do not match for ", test_pop)
  }

  # Predicted site scores for test population using training model
  pred_scores <- as.data.frame(predict(rda_train, newdata = env_test_scaled, type = "lc", scaling = 2))
  pred_scores$Sample <- rownames(pred_scores)
  pred_scores$Population <- test_pop
  write.csv(pred_scores, file.path(out_dir, paste0("RDA_lopo_scores", test_pop ,".csv")))

  # Observed site scores = from the actual RDA model for the test population
  rda_test <- readRDS(file.path(rda_dir, paste0("rda_", test_pop, ".rds")))
  obs_scores <- as.data.frame(scores(rda_test, display = "sites", scaling = 2))
  obs_scores$Sample <- rownames(obs_scores)
  obs_scores$Population <- test_pop

  # Combine observed and predicted
  combined <- obs_scores %>%
    select(Sample, RDA1_obs = RDA1, RDA2_obs = RDA2) %>%
    left_join(
      pred_scores %>%
        select(Sample, Population, RDA1_pred = RDA1, RDA2_pred = RDA2),
      by = "Sample"
    ) %>%
    mutate(test_pop = test_pop)

  return(combined)
}

# ============================================================
# 5. Run LOPO across all populations
# ============================================================
lopo_results <- map_df(populations, ~run_lopo_rda(.x, populations, metadata, env_scaled, gen_dir, rda_dir))

# Save combined results
write_csv(lopo_results, file.path(out_dir, "RDA_LOPO_predictions.csv"))

