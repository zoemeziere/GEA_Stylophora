library(vegan)
library(tidyr)

setwd("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/GEA/RDA")

# Script to create density plots for distances 

distances <- readRDS("distance_results.rds")
distances <- subset(distances, !(TrainPop == "Lizard" & TestPop == "Moore"))
distances <- subset(distances, !(TrainPop == "Lizard" & TestPop == "Heron"))
distances <- subset(distances, !(TrainPop == "Lizard" & TestPop == "Pelorus"))
distances <- subset(distances, !(TrainPop == "Lizard" & TestPop == "OffshoreCentral"))

custom_colors <- c("Global" = "grey40", "Heron" = "#5CBED1", "Pelorus" = "#F2C738",
  "OffshoreCentral" = "#1F7D1E", "Moore" = "#F39237", "Lizard" = "#B05102")

distances$TrainPop <- factor(distances$TrainPop,
                             levels = c("Global", "Lizard", "Moore", "Pelorus", "OffshoreCentral", "Heron"))

distances$TestPop <- factor(distances$TestPop, 
                            levels = c("Lizard", "Moore", "Pelorus", "OffshoreCentral", "Heron"))

ggplot(distances, aes(x = Distance, fill = TrainPop)) +
  geom_density(alpha = 0.9) +  
  facet_grid(TestPop ~ TrainPop, scales = "fixed") +  
  scale_fill_manual(values = custom_colors) + 
  theme_minimal() +
  labs(x = "Distance", y = "Density") +
  theme(legend.position = "none") 

