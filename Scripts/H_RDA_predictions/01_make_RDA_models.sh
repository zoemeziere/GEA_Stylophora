module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(vegan)
library(dplyr)

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

EOF
