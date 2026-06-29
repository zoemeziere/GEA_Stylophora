library(vegan)
library(dplyr)

# Population level RDA models

populations <- c("Heron", "OffshoreCentral", "Pelorus", "Moore", "Lizard")

SpisTaxon1_metadata <- read.csv("WGSpisTaxon1_Metadata.csv")
X <- read.csv("env_data/env_Spis_ind_uncor_unscaled.csv", header = TRUE)

for (pop in populations) {
   rds_file <- paste0("gen_data/", pop, "_linked_imputed.rds")
   gen_pop <- readRDS(rds_file)
   pop_data <- SpisTaxon1_metadata[SpisTaxon1_metadata$Population == pop, ]
   env_pop <- X[X$'Samples.renames' %in% pop_data$'Samples.renames', ]
   env_pop <- env_pop[match(rownames(gen_pop), env_pop$'Samples.renames'), ]
   rda_pop <- rda(gen_pop ~ ., data=env_pop[,4:9], scale = TRUE)
   saveRDS(rda_pop, paste0("rda_", pop, "_v2.rds"))
}

# GBR-wide RDA models


SpisTaxon1_metadata <- read.csv("WGSpisTaxon1_Metadata.csv")
gen <- readRDS("gen_data/Global_linked_imputed.rds")

rownames(gen) <- gsub("-", "_", rownames(gen))
SpisTaxon1_metadata$Sample_names <- gsub("-", "_", SpisTaxon1_metadata$Sample_names)

idx <- match(rownames(gen), SpisTaxon1_metadata$Sample_names)
cat("NAs in match:", sum(is.na(idx)), "\n")

SpisTaxon1_metadata <- SpisTaxon1_metadata[idx, ]

# Environmental data
X <- read.csv("env_Spis_ind_uncor_unscaled.csv", header = TRUE)
env_scaled <- scale(X[, 4:9])
pca_env <- prcomp(env_scaled, center = FALSE, scale. = FALSE)
pca_df <- cbind(Samples.renames = X$Samples.renames,
                as.data.frame(pca_env$x))
pca_df$Samples.renames <- gsub("-", "_", pca_df$Samples.renames)
pca_df <- pca_df[match(rownames(gen), pca_df$Samples.renames), ]
PCs_used <- pca_df[, c("PC1", "PC2", "PC3")]

# Geography
geography <- data.frame(
  lat  = SpisTaxon1_metadata$decimalLatitude,
  long = SpisTaxon1_metadata$decimalLongitude)

# RDA partialling out geography
partial_rda <- rda(gen ~ PC1 + PC2 + PC3 + Condition(lat + long), data = cbind(PCs_used, geography))
saveRDS(partial_rda, "rda_gbr_partial.rds")
print(RsquareAdj(partial_rda)) 

# Geography model
rda_geo <- rda(X = gen, Y = geography)
print(RsquareAdj(rda_geo))
saveRDS(rda_geo, "rda_gbr_geography.rds")