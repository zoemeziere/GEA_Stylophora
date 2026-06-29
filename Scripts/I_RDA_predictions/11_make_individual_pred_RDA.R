library(vegan)

gen <- readRDS("gen_data/Global_linked_imputed.rds")
rownames(gen) <- gsub("-", "_", rownames(gen))

SpisTaxon1_metadata <- read.csv("WGSpisTaxon1_Metadata.csv")
SpisTaxon1_metadata$Sample_names <- gsub("-", "_", SpisTaxon1_metadata$Sample_names)

idx <- match(rownames(gen), SpisTaxon1_metadata$Sample_names)
SpisTaxon1_metadata <- SpisTaxon1_metadata[idx, ]

# Recreate env PCs exactly as original
X <- read.csv("env_Spis_ind_uncor_unscaled.csv", header = TRUE)
env_scaled <- scale(X[, 4:9])
pca_env <- prcomp(env_scaled, center = FALSE, scale. = FALSE)
pca_df <- cbind(Samples.renames = X$Samples.renames,
                as.data.frame(pca_env$x))
pca_df$Samples.renames <- gsub("-", "_", pca_df$Samples.renames)
pca_df <- pca_df[match(rownames(gen), pca_df$Samples.renames), ]
PCs_used <- pca_df[, c("PC1", "PC2", "PC3")]

geography <- data.frame(
  lat  = SpisTaxon1_metadata$decimalLatitude,
  long = SpisTaxon1_metadata$decimalLongitude)

all_data <- cbind(PCs_used, geography)

# Global RDA
env_model <- readRDS("rda_models/rda_Global.rds")
total <- env_model$tot.chi

# Unique contribution of each predictor
rda_PC1 <- rda(gen ~ PC1 + Condition(PC2 + PC3 + lat + long), data = all_data)
rda_PC2 <- rda(gen ~ PC2 + Condition(PC1 + PC3 + lat + long), data = all_data)
rda_PC3 <- rda(gen ~ PC3 + Condition(PC1 + PC2 + lat + long), data = all_data)
rda_lat <- rda(gen ~ lat + Condition(PC1 + PC2 + PC3 + long), data = all_data)
rda_long <- rda(gen ~ long + Condition(PC1 + PC2 + PC3 + lat), data = all_data)

# Extract unique fractions
unique_PC1 <- rda_PC1$CCA$tot.chi / total
unique_PC2 <- rda_PC2$CCA$tot.chi / total
unique_PC3 <- rda_PC3$CCA$tot.chi / total
unique_lat <- rda_lat$CCA$tot.chi / total
unique_long <- rda_long$CCA$tot.chi / total

results <- data.frame(
  predictor = c("PC1", "PC2", "PC3", "lat", "long"),
  proportion = c(unique_PC1, unique_PC2, unique_PC3, unique_lat, unique_long)
)

print(results)

saveRDS(results, "variance_partition_individual_predictors.rds")