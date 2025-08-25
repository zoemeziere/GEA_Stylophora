library(vegan) 
library(ggplot2)
library(data.table)
library(car)
library(corrplot)

setwd("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/GEA/RDA")
SpisTaxon1_metadata <- read.csv("WGSpisTaxon1_Metadata.csv")

# Read rda models
rda_global <- readRDS("training_rda_models/rda_global.rds")
rda_Heron <- readRDS("training_rda_models/rda_Heron.rds")
rda_Pelorus <- readRDS("training_rda_models/rda_Pelorus.rds")
rda_OffshoreCentral <- readRDS("training_rda_models/rda_OffshoreCentral.rds")
rda_Moore <- readRDS("training_rda_models/rda_Moore.rds")
rda_Lizard <- readRDS("training_rda_models/rda_Lizard.rds")

# Eigenvalues
a <- screeplot(rda)
a$y
RDA1_propvar <- round(a$y[1]/sum(a$y),3)
RDA2_propvar <- round(a$y[2]/sum(a$y),3)

# Relative importance of env. predictors
anova_results <- anova.cca(rda, by = "term")
importance <- data.frame(Predictor = rownames(anova_results), Variance = anova_results$Variance)

importance <- readRDS("importance.rds")
total_variance <- sum(rda$CCA$eig, rda$CA$eig)
importance$Proportion <- importance$Variance / total_variance
importance_no_residuals <- importance[importance$Predictor != "Residual", ]

ggplot(importance_no_residuals, aes(x = reorder(Predictor, Proportion), y = Proportion)) +
  geom_bar(stat = "identity", fill = "grey70") +
  coord_flip() + 
  labs(x = "Environmental Predictor", y = "Variance Explained") +
  theme_minimal()

# Colour palettes
# For GBR-level
colors <- c("#5C9FD1","#5CBED1","#1F7D1E","#F2C738", "#F39237", "#B05102")

SpisTaxon1_metadata$Population <- factor(SpisTaxon1_metadata$Population, 
                                         levels = c("LadyMusgrave", "Heron", "OffshoreCentral", "Pelorus", "Moore", "Lizard"))
bg_colors <- colors[SpisTaxon1_metadata$Population]
pch_depth <- ifelse(SpisTaxon1_metadata$EcoZoneID == "Shallow", 21, 24)

# For population-level
SpisTaxon1_metadata_pop <- SpisTaxon1_metadata[SpisTaxon1_metadata$Population=="Heron",] 

palette <- colorRampPalette(c("lightblue", "darkblue"))
palette <- colorRampPalette(c("lightgreen", "darkgreen"))
palette <- colorRampPalette(c("lightyellow", "yellow"))
palette <- colorRampPalette(c("burlywood1", "darkorange2"))
palette <- colorRampPalette(c("indianred", "darkred"))

eco_location_ids <- SpisTaxon1_metadata_pop$EcoLocationID_short
unique_eco_location_ids <- unique(eco_location_ids <- SpisTaxon1_metadata_pop$EcoLocationID_short)
unique_eco_location_ids <- unique(eco_location_ids)
color_values <- palette(length(unique_eco_location_ids))
eco_location_colors <- setNames(color_values, unique_eco_location_ids)
color_values <- palette(length(unique_eco_location_ids))
eco_location_colors <- setNames(color_values, unique_eco_location_ids)
bg_colors <- eco_location_colors[eco_location_ids]

pch_depth <- ifelse(SpisTaxon1_metadata_pop$EcoZoneID == "Shallow", 21, 24)

# For all
varex <- summary(rda_Heron)$cont$importance[2, ] * 100
site_scores <- scores(rda_Heron, display = "sites", scaling = 3)

# Plot
svg("rda_Heron.svg", width=8, height=8)

plot(rda_Heron, type = "n", scaling = 3,
     xlab = paste0("RDA1 (", round(varex[1], 1), "%)"),
     ylab = paste0("RDA2 (", round(varex[2], 1), "%)"),
    cex.lab = 1.5,
    cex.axis = 1.2,
    lwd = 2,
    xlim = range(site_scores[,1]) * 1.1,
    ylim = range(site_scores[,2]) * 1.1)

points(site_scores[,1], site_scores[,2], cex = 3,
       pch = pch_depth,
       col = "gray32",
       bg = bg_colors)

text(rda_Heron, scaling = 3, display = "bp", col = "black", cex = 1)

dev.off()

# How much genetic variation is explained by env predictors in each population?
RsquareAdj(rda_heron) # constrained ordination explains 1.4% of variation
RsquareAdj(rda_central) # constrained ordination explains 1.0% of variation
RsquareAdj(rda_pelorus) # constrained ordination explains 1.8% of variation
RsquareAdj(rda_moore) # constrained ordination explains 1.7% of variation
RsquareAdj(rda_lizard) # constrained ordination explains 2.1% of variation
RsquareAdj(rda_global) # constrained ordination explains 4.2% of variation

# Do environmental variables have the same importance across populations? (run for each rda model)
eig <- rda_heron$CCA$eig
loadings <- rda_heron$CCA$biplot

contrib_matrix <- sweep(loadings^2, 2, eig, FUN = "*")

var_contrib <- rowSums(contrib_matrix)
prop_contrib <- var_contrib / sum(eig)

contrib_df <- data.frame(
  Variable = rownames(loadings),
  VarianceExplained = var_contrib,
  RelativeProportion = prop_contrib
)

print(contrib_df)