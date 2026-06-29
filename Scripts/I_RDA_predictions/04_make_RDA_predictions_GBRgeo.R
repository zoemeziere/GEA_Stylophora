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

# Reorder metadata to match gen row order (same as model fitting)
idx <- match(rownames(gen), metadata$Sample_names)
cat("NAs in match:", sum(is.na(idx)), "\n")
metadata <- metadata[idx, ]
cat("Order matches:", all(rownames(gen) == metadata$Sample_names), "\n")

# Load pre-built GBR-wide geography model
rda_geo <- readRDS("rda_gbr_geography.rds")

# Geography for all individuals
geography_all <- data.frame(
  lat  = metadata$decimalLatitude,
  long = metadata$decimalLongitude,
  row.names = metadata$Sample_names)

# ============================================================
# 3. Populations and directories
# ============================================================
populations <- c("Heron", "Lizard", "Moore", "OffshoreCentral", "Pelorus")
rda_dir <- "rda_models"
out_dir <- "rda_geography_lopo_predictions"
dir.create(out_dir, showWarnings = FALSE)

# ============================================================
# 4. Predict for each test population using geography model
# ============================================================
results <- list()

for (test_pop in populations) {
  message("=== Predicting for: ", test_pop, " ===")

  # Subset geography for test population
  idx_pop <- which(metadata$Population == test_pop)
  geo_test <- geography_all[idx_pop, , drop = FALSE]

  # Predicted scores using GBR geography model
  pred_scores <- as.data.frame(predict(rda_geo, newdata = geo_test, type = "lc", scaling = 2))
  pred_scores$Sample     <- rownames(pred_scores)
  pred_scores$Population <- test_pop

  # Observed scores from population-specific RDA model
  rda_test   <- readRDS(file.path(rda_dir, paste0("rda_", test_pop, ".rds")))
  obs_scores <- as.data.frame(scores(rda_test, display = "sites", scaling = 2))
  obs_scores$Sample <- gsub("-", "_", rownames(obs_scores))  # fix hyphens
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
            file.path(out_dir, paste0("RDA_geography_pred_", test_pop, ".csv")),
            row.names = FALSE)

  results[[test_pop]] <- combined
}

# ============================================================
# 5. Combine and save
# ============================================================
all_results <- do.call(rbind, results)
write.csv(all_results,
          file.path(out_dir, "RDA_geography_all_predictions.csv"),
          row.names = FALSE)

cat("Mean Euclidean distance per population:\n")
print(tapply(all_results$euclidean_dist, all_results$Population, mean))