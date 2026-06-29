# ============================================================
# 1. Libraries
# ============================================================
library(vegan)

# ============================================================
# 2. Data
# ============================================================
metadata <- read.csv("WGSpisTaxon1_Metadata.csv")
gen <- readRDS("gen_data/Global_linked_imputed.rds")

# Standardise separators
rownames(gen) <- gsub("-", "_", rownames(gen))
metadata$Sample_names <- gsub("-", "_", metadata$Sample_names)

# Reorder metadata to match gen row order
idx <- match(rownames(gen), metadata$Sample_names)
cat("NAs in match:", sum(is.na(idx)), "\\n")
metadata <- metadata[idx, ]
cat("Order matches:", all(rownames(gen) == metadata$Sample_names), "\\n")

# Load pre-built partial RDA model (Env | Lat + Long)
rda_partial <- readRDS("rda_gbr_partial.rds")

# ============================================================
# 3. Recreate environmental PCs (must match original model exactly)
# ============================================================
X <- read.csv("env_Spis_ind_uncor_unscaled.csv", header = TRUE)
env_scaled <- scale(X[, 4:9])
pca_env <- prcomp(env_scaled, center = FALSE, scale. = FALSE)

pca_df <- cbind(Samples.renames = X$Samples.renames,
                as.data.frame(pca_env$x))
pca_df$Samples.renames <- gsub("-", "_", pca_df$Samples.renames)
pca_df <- pca_df[match(rownames(gen), pca_df$Samples.renames), ]
PCs_used <- pca_df[, c("PC1", "PC2", "PC3")]
rownames(PCs_used) <- rownames(gen)

# Geography (needed as condition in partial model)
geography_all <- data.frame(
  lat  = metadata$decimalLatitude,
  long = metadata$decimalLongitude,
  row.names = metadata$Sample_names)

# Combined predictor data frame (env + geo condition)
all_predictors <- cbind(PCs_used, geography_all)

# ============================================================
# 4. Populations and directories
# ============================================================
populations <- c("Heron", "Lizard", "Moore", "OffshoreCentral", "Pelorus")
rda_dir <- "rda_models"
out_dir <- "rda_partial_lopo_predictions"
dir.create(out_dir, showWarnings = FALSE)

# ============================================================
# 5. Predict for each test population using partial RDA model
# ============================================================
results <- list()

for (test_pop in populations) \{
  message("=== Predicting for: ", test_pop, " ===")

  # Subset predictors for test population
  idx_pop <- which(metadata$Population == test_pop)
  newdata_test <- all_predictors[idx_pop, , drop = FALSE]

  # Predicted scores using partial RDA model
  pred_scores <- as.data.frame(predict(rda_partial, newdata = newdata_test, type = "lc", scaling = 2))
  pred_scores$Sample     <- rownames(pred_scores)
  pred_scores$Population <- test_pop

  # Observed scores from population-specific RDA model
  rda_test   <- readRDS(file.path(rda_dir, paste0("rda_", test_pop, ".rds")))
  obs_scores <- as.data.frame(scores(rda_test, display = "sites", scaling = 2))
  obs_scores$Sample <- gsub("-", "_", rownames(obs_scores))
  obs_scores$Population <- test_pop
  
  # Combine observed vs predicted
  combined <- merge(
    obs_scores[ , c("Sample", "RDA1", "RDA2")],
    pred_scores[ , c("Sample", "RDA1", "RDA2")],
    by = "Sample",
    suffixes = c("_obs", "_pred"))
  combined$Population <- test_pop

  # Euclidean distance
  combined$euclidean_dist <- sqrt(
    (combined$RDA1_obs - combined$RDA1_pred)^2 +
    (combined$RDA2_obs - combined$RDA2_pred)^2)

  write.csv(combined,
            file.path(out_dir, paste0("RDA_partial_pred_", test_pop, ".csv")),
            row.names = FALSE)

  results[[test_pop]] <- combined
}

# ============================================================
# 6. Combine and save
# ============================================================
all_results <- do.call(rbind, results)
write.csv(all_results,
          file.path(out_dir, "RDA_partial_all_predictions.csv"),
          row.names = FALSE)

cat("Mean Euclidean distance per population:\\n")
print(tapply(all_results$euclidean_dist, all_results$Population, mean))
}