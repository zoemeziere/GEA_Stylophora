#!/bin/bash --login
#SBATCH --job-name="RDA"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=100G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=1:00:00         # walltime
#SBATCH --account=a_riginos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o rdaforest_%A.o         # standard output
#SBATCH -e rdaforest_%A.e             # standard error

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(vegan)
library(dplyr)
library(ggplot2)

# ---- 1. Define populations, models, and color palette ----
populations <- c("LadyMusgrave", "Heron", "OffshoreCentral", "Pelorus", "Moore", "Lizard")

# Load all RDA models into a named list
rda_models <- setNames(
  lapply(populations, function(pop) {
    readRDS(paste0("rda_models/rda_", pop, ".rds"))
  }),
  populations
)

# Global GBR color palette (south to north)
pop_colors <- c(
  LadyMusgrave = "#5C9FD1",
  Heron        = "#5CBED1",
  Pelorus      = "#1F7D1E",
  OffshoreCentral = "#F2C738",
  Moore        = "#F39237",
  Lizard       = "#B05102"
)

# ---- 2. Define function to plot one population ----
plot_rda_population <- function(pop, metadata, model, output_dir = "rda_plots") {
  
  # Create directory if needed
  dir.create(output_dir, showWarnings = FALSE)
  
  # Subset metadata for this population
  meta_pop <- subset(metadata, Population == pop)
  
  # Choose a local palette per population
  palette_list <- list(
    LadyMusgrave = colorRampPalette(c("lightblue", "darkblue")),
    Heron        = colorRampPalette(c("lightgreen", "darkgreen")),
    OffshoreCentral = colorRampPalette(c("lightyellow", "goldenrod")),
    Pelorus      = colorRampPalette(c("burlywood1", "darkorange2")),
    Moore        = colorRampPalette(c("indianred", "darkred")),
    Lizard       = colorRampPalette(c("orchid", "purple4"))
  )
  palette <- palette_list[[pop]]
  
  # Assign EcoLocationID colors
  unique_sites <- unique(meta_pop$EcoLocationID_short)
  eco_colors <- setNames(palette(length(unique_sites)), unique_sites)
  bg_colors <- eco_colors[meta_pop$EcoLocationID_short]
  
  # Point shapes by depth zone
  pch_depth <- ifelse(meta_pop$EcoZoneID == "Shallow", 21, 24)
  
  # RDA summary
  varex <- summary(model)$cont$importance[2, ] * 100
  site_scores <- scores(model, display = "sites", scaling = 3)
  
  # ---- 3. Plot and save ----
  svg(file.path(output_dir, paste0("rda_", pop, ".svg")), width = 8, height = 8)
  
  plot(model, type = "n", scaling = 3,
       xlab = paste0("RDA1 (", round(varex[1], 1), "%)"),
       ylab = paste0("RDA2 (", round(varex[2], 1), "%)"),
       cex.lab = 1.5, cex.axis = 1.2, lwd = 2,
       xlim = range(site_scores[, 1]) * 1.1,
       ylim = range(site_scores[, 2]) * 1.1)
  
  points(site_scores[, 1], site_scores[, 2], cex = 3,
         pch = pch_depth, col = "gray32", bg = bg_colors)
  
  text(model, scaling = 3, display = "bp", col = "black", cex = 1)
  
  dev.off()
  
  message("✅ RDA plot saved for ", pop)
}

# ---- 4. Run for all populations ----
lapply(populations, function(pop) {
  plot_rda_population(pop, SpisTaxon1_metadata, rda_models[[pop]])
})

EOF
