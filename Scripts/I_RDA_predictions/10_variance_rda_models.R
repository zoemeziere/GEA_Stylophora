library(ggplot2)
library(dplyr)
library(cowplot)

# ── Load models and results ────────────────────────────────────────────────────
results       <- readRDS("variance_partition_individual_predictors.rds")
env_model     <- readRDS("rda_models/rda_Global.rds")
geo_model     <- readRDS("rda_gbr_geography.rds")
partial_model <- readRDS("rda_gbr_partial.rds")

# ── Variance components ────────────────────────────────────────────────────────
total           <- env_model$tot.chi
env_only        <- env_model$CCA$tot.chi
geo_only        <- geo_model$CCA$tot.chi
unique_env      <- partial_model$CCA$tot.chi
confounded      <- env_only - unique_env
unique_geo      <- geo_only - confounded
residual        <- total - env_only - unique_geo
total_explained <- unique_env + confounded + unique_geo
conf_chi        <- confounded

# ── Individual predictor unique fractions (as proportion of total) ─────────────
unique_PC1  <- results$proportion[results$predictor == "PC1"]
unique_PC2  <- results$proportion[results$predictor == "PC2"]
unique_PC3  <- results$proportion[results$predictor == "PC3"]
unique_lat  <- results$proportion[results$predictor == "lat"]
unique_long <- results$proportion[results$predictor == "long"]

# ── Shared variance between PCs (inter-PC collinearity) ───────────────────────
pc_shared_env     <- env_only - (unique_PC1 + unique_PC2 + unique_PC3) * total - conf_chi
pc_shared_partial <- unique_env - (unique_PC1 + unique_PC2 + unique_PC3) * total

# ── Colour palette ─────────────────────────────────────────────────────────────
cols <- c(
  "Residual"    = "#999999",
  "Full Model"  = "#3B1F5E",
  "Confounded"  = "#a8c8a0",
  "Shared (PCs)"= "#d3c4a0",
  "long"        = "#4A7FAF",
  "lat"         = "#7BA7D0",
  "PC3"         = "#B8860B",
  "PC2"         = "#D4A843",
  "PC1"         = "#E8C87A"
)

# ── Plot function ──────────────────────────────────────────────────────────────
make_plot <- function(left_df, right_df, title) {
  df <- bind_rows(left_df, right_df)
  df$bar <- factor(df$bar, levels = c("All Variance", "Explainable Variance"))
  df$fraction <- factor(df$fraction,
                        levels = c("Residual", "Full Model",
                                   "Confounded", "Shared (PCs)",
                                   "long", "lat",
                                   "PC3", "PC2", "PC1"))
  ggplot(df, aes(x = bar, y = value, fill = fraction)) +
    geom_col() +
    geom_text(aes(label = scales::percent(value, accuracy = 1)),
              position = position_stack(vjust = 0.5), size = 3) +
    scale_y_continuous(labels = scales::percent) +
    scale_fill_manual(values = cols, drop = FALSE) +
    theme_classic() +
    labs(x = NULL, y = NULL, fill = NULL, title = title)
}

# ── Plot 1: Environmental model (rda_Global) ───────────────────────────────────
p1 <- make_plot(
  left_df = data.frame(
    bar      = "All Variance",
    fraction = c("Full Model", "Residual"),
    value    = c(env_only, total - env_only) / total
  ),
  right_df = data.frame(
    bar      = "Explainable Variance",
    fraction = c("PC1", "PC2", "PC3", "Confounded", "Shared (PCs)"),
    value    = c(unique_PC1 * total, unique_PC2 * total, unique_PC3 * total,
                 conf_chi, pc_shared_env) / env_only
  ),
  title = "Environmental model"
)

# ── Plot 2: Geography model ────────────────────────────────────────────────────
geo_denom <- (unique_lat + unique_long) * total + conf_chi
p2 <- make_plot(
  left_df = data.frame(
    bar      = "All Variance",
    fraction = c("Full Model", "Residual"),
    value    = c(geo_only, total - geo_only) / total
  ),
  right_df = data.frame(
    bar      = "Explainable Variance",
    fraction = c("lat", "long", "Confounded"),
    value    = c(unique_lat * total, unique_long * total, conf_chi) / geo_denom
  ),
  title = "Geography model"
)

# ── Plot 3: Partial model (Env | Geography) ────────────────────────────────────
p3 <- make_plot(
  left_df = data.frame(
    bar      = "All Variance",
    fraction = c("Full Model", "Residual"),
    value    = c(unique_env, total - unique_env) / total
  ),
  right_df = data.frame(
    bar      = "Explainable Variance",
    fraction = c("PC1", "PC2", "PC3", "Shared (PCs)"),
    value    = c(unique_PC1 * total, unique_PC2 * total, unique_PC3 * total,
                 pc_shared_partial) / unique_env
  ),
  title = "Partial model (Env | Geography)"
)

# ── Combine with single legend ─────────────────────────────────────────────────
legend <- get_legend(p3 + theme(legend.position = "right"))

final_plot <- plot_grid(
  p1 + theme(legend.position = "none"),
  p2 + theme(legend.position = "none"),
  p3 + theme(legend.position = "none"),
  legend,
  nrow = 1,
  rel_widths = c(1, 1, 1, 0.4)
)

print(final_plot)

ggsave("variance_partition_plots.pdf", final_plot, width = 14, height = 6)
ggsave("variance_partition_plots.png", final_plot, width = 14, height = 6, dpi = 300)