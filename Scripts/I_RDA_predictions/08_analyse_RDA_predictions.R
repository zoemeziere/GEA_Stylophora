library(ggplot2)
library(dplyr)
library(viridis)

loop <- read.csv("RDA_LOPO_predictions_PC_axes.csv") # global --> one pop
test<-read.csv("RDA_crossval_predictions_PC_axes.csv") # one pop --> another pop
geography<-read.csv("RDA_LOPO_predictions_geography.csv") # global geography --> one pop
partial<-read.csv("RDA_LOPO_predictions_partial.csv") # global partial --> one pop

loop2 <- loop %>%
  mutate(method = "LOPO_global", train_pop = "Global")

test2 <- test %>%
  mutate(method = "Cross_population", train_pop = sub("_to_.*", "", comparison))

geography2 <- geography %>%
  mutate(method = "LOPO_global", train_pop = "Global_geography")

partial2 <- partial %>%
  mutate(method = "LOPO_global", train_pop = "Global_partial")

merged_df <- bind_rows(loop2, test2, geography2, partial2)

# Plot predicted and observed scores
custom_colors <- c(
  "Global" = "grey40",
  "Global_geography" = "grey60",
  "Global_partial" = "grey80",
  "Heron" = "#5CBED1",
  "Pelorus" = "#F2C738",
  "OffshoreCentral" = "#1F7D1E",
  "Moore" = "#F39237",
  "Lizard" = "#B05102")

ggplot(merged_df) +
  geom_point(aes(x = RDA1_obs, y = RDA2_obs), color = "black", size = 5, alpha = 0.6) +
  geom_point(aes(x = RDA1_pred, y = RDA2_pred, fill = train_pop),
             shape = 21, color = "black", stroke = 0.5, size = 4) +
  scale_fill_manual(values = custom_colors) +
  facet_wrap(~ Population, scales = "free") +
  labs(x = "RDA1", y = "RDA2", color = "Training Population", shape = "Prediction Type") +
  scale_color_manual(values = custom_colors) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

# Euclidean distances
merged_df <- merged_df %>%
  mutate(deviation = sqrt((RDA1_pred - RDA1_obs)^2 + (RDA2_pred - RDA2_obs)^2))

summary_train <- merged_df %>%
  group_by(train_pop, Population, method) %>%
  summarise(
    mean_dev = mean(deviation, na.rm = TRUE),
    median_dev = median(deviation, na.rm = TRUE),
    sd_dev = sd(deviation, na.rm = TRUE),
    n = n()
  ) %>%
  arrange(mean_dev)

# Heatmap
order <- c("Global", "Global_geography", "Global_partial", "Lizard", "Moore", "OffshoreCentral", "Pelorus", "Heron")

summary_train <- summary_train %>%
  mutate(
    train_pop  = factor(train_pop,  levels = order),
    Population = factor(Population, levels = order))

ggplot(summary_train, aes(x = Population, y = train_pop, fill = log10(mean_dev))) +
  geom_tile(color = "white") +
  scale_y_discrete(limits = rev(levels(summary_train$train_pop))) +
  scale_fill_viridis(option = "plasma", direction = 1, limits = c(1, 3.5)) + 
  labs(x = "Test Population", y = "Training Population", fill = "log10(Distance)") +
  theme_bw()

# Boxplots
custom_colors <- c(
  "Global" = "grey40",
  "Global_geography" = "grey60",
  "Global_partial" = "grey80",
  "Heron" = "#5CBED1",
  "Pelorus" = "#F2C738",
  "OffshoreCentral" = "#1F7D1E",
  "Moore" = "#F39237",
  "Lizard" = "#B05102")

merged_df$train_pop <- factor(merged_df$train_pop, levels = names(custom_colors))

ggplot(merged_df, aes(x = train_pop, y = log10(deviation), fill = train_pop)) +
  geom_boxplot(outlier.alpha = 0.3) +
  facet_wrap(~ Population, scales = "free") +
  scale_fill_manual(values = custom_colors) + 
  labs(
    x = "Training Population",
    y = "Deviation (log10 scale)",
    fill = "Training Population",
    title = "Distribution of Prediction Deviations") +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5))

