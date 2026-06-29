library(ggplot2)
library(tidyr)
library(dplyr)

# Load the data
RDA_offset_fut <- readRDS("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/Genomic_offset/RDA_offset_fut.rds")

# Assign region based on latitude
RDA_offset_fut$Region <- cut(
  RDA_offset_fut$y,
  breaks = c(-Inf, -21.5, -18, -15.5, Inf),
  labels = c("South", "Central", "North", "Far North")
)

# Inspect how many points per region
table(RDA_offset_fut$Region)

# Extract SSP and Decade from combined field
RDA_offset_fut$SSP <- gsub("_.*", "", RDA_offset_fut$SSP_decade)
RDA_offset_fut$Decade <- gsub(".*_", "", RDA_offset_fut$SSP_decade)

# Create a combined scenario label for faceting (optional)
RDA_offset_fut$Scenario <- paste(RDA_offset_fut$SSP, RDA_offset_fut$Decade, sep = "\n")

# Violin plot: Global_offset per Region
ggplot(RDA_offset_fut, aes(x = Region, y = Global_offset, fill = Region)) +
  geom_violin(trim = FALSE, scale = "width", color = "black", alpha = 0.6) +
 geom_boxplot(width = 0.12, outlier.shape = NA, alpha = 0.8, color = "black") +
  scale_fill_manual(
    values = c("South" = "#5CBED1", "Central" = "#7BB52B", "North" = "#B05102", "Far North" = "firebrick")) +
  labs(x = "Region", y = "Genomic Offset", title = "Genomic Offset by Region and Future Scenario") +
  facet_wrap(~ Scenario, ncol = 3) +
  theme_bw() +
  theme(legend.position = "none")
