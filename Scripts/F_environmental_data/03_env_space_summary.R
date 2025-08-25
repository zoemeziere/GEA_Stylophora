library(ggplot2)
library(tidyr)
library(dplyr)
library(vegan)

env_rda_unscaled <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/environmental_data/gbr-wide_env/rdaEnv_site_unscaled.csv")
env_rda_scaled <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/environmental_data/gbr-wide_env/rdaEnv_site_scaled.csv")

env_vars <- env_rda_scaled[, c("ubedmean", "Turbidity_mean", "PAR_mean", 
                                 "temp_mean", "DistanceLand", "MonthlyRange")]

location_colors <- c("LadyMusgrave" = "#5C9FD1","Heron" = "#5CBED1",
  "Chicken" = "#A2B52B", "Davies" = "#7BB52B", "LittleBroadhurst" = "#1F7D1E", 
  "Pelorus" = "#F2C738","Moore" = "#F39237","Lizard" = "#B05102")

# PCA plot of environmental space (within and between populations)

pca_res <- prcomp(env_vars)
pca_df <- as.data.frame(pca_res$x)
pca_df$Depth <- env_rda_scaled$Depth
pca_df$Population <- env_rda_scaled$Reef

pca_df$Population <- factor(pca_df$Population, levels = names(location_colors))

# Env. loadings
env_loadings <- as.data.frame(pca_res$rotation[, 1:2])  # PC1 & PC2 loadings
env_loadings$Variable <- rownames(env_loadings)
arrow_scale <- 3  # adjust to make arrows fit nicely
env_arrows <- env_loadings
env_arrows$PC1 <- env_arrows$PC1 * arrow_scale
env_arrows$PC2 <- env_arrows$PC2 * arrow_scale

ggplot(pca_df, aes(x = PC1, y = PC2, fill = Population, shape = Depth)) +
  geom_point(size = 6, color = "black") +   # black outline
  geom_segment(data = env_arrows,
               aes(x = 0, y = 0, xend = PC1, yend = PC2),
               arrow = arrow(length = unit(0.3, "cm")),
               inherit.aes = FALSE,
               color = "black") +
  geom_text(data = env_arrows,
            aes(x = PC1, y = PC2, label = Variable),
            inherit.aes = FALSE,
            color = "black", vjust = -0.5, size = 4) +
  scale_fill_manual(values = location_colors) +
  scale_shape_manual(values = c("Shallow" = 21, "Deep" = 24)) +  # filled point shapes
  theme_bw() +
  labs(
    x = paste0("PC1 (", round(summary(pca_res)$importance[2, 1] * 100, 1), "%)"),
    y = paste0("PC2 (", round(summary(pca_res)$importance[2, 2] * 100, 1), "%)")
  )

# Box plots of environmental heterogeneity within reefs - scaled
location_colors <- c(
  "LadyMusgrave" = "#5C9FD1",
  "Heron"        = "#5CBED1",
  "Pelorus"      = "#F2C738",
  "Central"      = "#7BB52B",
  "Moore"        = "#F39237",
  "Lizard"       = "#B05102")

env_long <- env_rda_unscaled %>% mutate(
         Population = recode(Population, "Chicken" = "central", "LittleBroadhurst" = "central", "Davies" = "central"),
         Population = factor(Population, levels = c("LadyMusgrave", "Heron", "Pelorus", "Central", "Moore", "Lizard"))) %>% pivot_longer(
         cols = c(ubedmean, Turbidity_mean, PAR_mean, temp_mean, dist_to_shore, temp_monthly_range),
         names_to = "Variable", values_to = "Value")

ggplot(env_long, aes(x = Population, y = Value, fill = Population)) +
  geom_boxplot(outlier.shape = 21, outlier.colour = "black", alpha = 0.8) +
  scale_fill_manual(values = location_colors) +
  facet_wrap(~ Variable, scales = "free_y") +
  theme_bw(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none") + labs(
    x = "Population",
    y = "Scaled Value")


# Box plots of environmental heterogeneity within reefs - centred for each population
location_colors <- c(
  "LadyMusgrave" = "#5C9FD1",
  "Heron"        = "#5CBED1",
  "Pelorus"      = "#F2C738",
  "Central"      = "#7BB52B",
  "Moore"        = "#F39237",
  "Lizard"       = "#B05102"
)

env_long <- env_rda_unscaled %>%
  mutate(
    Population = recode(Population,
                        "Chicken" = "Central",
                        "LittleBroadhurst" = "Central",
                        "Davies" = "Central"),
    Population = factor(Population,
                        levels = c("LadyMusgrave", "Heron", "Pelorus",
                                   "Central", "Moore", "Lizard"))
  ) %>%
  pivot_longer(
    cols = c(ubedmean, Turbidity_mean, PAR_mean, temp_mean,
             dist_to_shore, temp_monthly_range),
    names_to = "Variable", values_to = "Value"
  ) %>%
  group_by(Population, Variable) %>%
  mutate(Value_centered = Value - mean(Value, na.rm = TRUE)) %>%
  ungroup()

ggplot(env_long, aes(x = Population, y = Value_centered, fill = Population)) +
  geom_boxplot(outlier.shape = 21, outlier.colour = "black", alpha = 0.8) +
  scale_fill_manual(values = location_colors) +
  facet_wrap(~ Variable, scales = "free_y") +
  theme_bw(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none") +
  labs(
    x = "Population",
    y = "Centered Value"
  )

# Correlation among all env variables
library(dplyr)
library(ggcorrplot)

all_env_ind_unscaled <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/environmental_data/gbr-wide_env/allVar_ind_unscaled.csv")
env_cat <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/environmental_data/gbr-wide_env/variables_categories.csv")

env_numeric <- all_env_ind_unscaled %>%
  select(where(is.numeric))

env_cat_filtered <- env_cat %>%
  filter(variable %in% colnames(env_numeric)) %>%
  arrange(category, variable)

env_numeric_ordered <- env_numeric[, env_cat_filtered$variable]

cor_mat <- cor(env_numeric_ordered, use = "pairwise.complete.obs", method = "pearson")
cor_mat[upper.tri(cor_mat)] <- NA

annotation_df <- data.frame(Category = env_cat_filtered$category)
rownames(annotation_df) <- env_cat_filtered$variable

pheatmap(cor_mat,
         cluster_rows = FALSE,
         cluster_cols = FALSE,
         annotation_col = annotation_df,
         annotation_row = annotation_df,
         show_rownames = FALSE,
         show_colnames = FALSE,
         fontsize = 8,
         main = "Correlation among environmental variables grouped by category",
         na_col = "white")  