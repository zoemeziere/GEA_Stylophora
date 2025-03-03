distance_results <- readRDS("distance_results.rds")

# Plot the distances as box plots
library(ggplot2)

ggplot(distance_results, aes(x = TestPop, y = Distance, fill = TrainPop)) +
  geom_boxplot() +
  labs(x = "Test Populations", y = "Distance", title = "Distances Between True and Predicted RDA Positions") +
  theme_minimal() +
  scale_fill_brewer(palette = "Set3") +  # Color palette for training populations
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
