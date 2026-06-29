library(vegan)
library(dplyr)
library(ggplot2)

# Plot population level models

populations <- c("Heron", "OffshoreCentral", "Pelorus", "Moore", "Lizard")

for (pop in populations) {
   rda_model <- readRDS(paste0("rda_models/rda_", pop, ".rds"))
   pdf(paste0("rda_", pop, "_ind.pdf"))
   plot(rda_model, type="n", scaling=3)
   points(rda_model, display="species", pch=20, cex=2, col="gray32", scaling=3)
   points(rda_model, display="sites", pch=21, cex=2, col="red", scaling=3)
   text(rda_model, display="bp", col="black", cex=1, scaling=3)
   dev.off()
}

# Plot GBR-wide models

model <- readRDS("rda_gbr_geography.rds") # Replace by model of interest
SpisTaxon1_metadata <- read.csv("WGSpisTaxon1_Metadata.csv")

pop_colors <- c(
  LadyMusgrave    = "#5C9FD1",
  Heron           = "#5CBED1",
  Pelorus         = "#F2C738",
  OffshoreCentral = "#7BB52B",
  Moore           = "#F39237",
  Lizard          = "#B05102"
)

ind_colors <- pop_colors[SpisTaxon1_metadata$Population]
cat("NAs in ind_colors:", sum(is.na(ind_colors)), "\n")

depth_pch <- ifelse(SpisTaxon1_metadata$EcoZoneID == "Shallow", 21, 24)

varex <- summary(model)$cont$importance[2, ] * 100
site_scores <- scores(model, display = "sites", scaling = 3)

svg("rda_geography.svg", width = 8, height = 8)

plot(model, type = "n", scaling = 3,
     xlab = paste0("RDA1 (", round(varex[1], 1), "%)"),
     ylab = paste0("RDA2 (", round(varex[2], 1), "%)"),
     cex.lab = 1.5, cex.axis = 1.2, lwd = 2,
     xlim = range(site_scores[, 1]) * 1.1,
     ylim = range(site_scores[, 2]) * 1.1)

points(site_scores[, 1], site_scores[, 2],
       cex = 3,
       pch = depth_pch,
       col = "gray32",
       bg  = ind_colors)

text(model, scaling = 3, display = "bp", col = "black", cex = 1.2)

legend("topright",
       legend = names(pop_colors),
       pt.bg  = pop_colors,
       pch    = 21,
       col    = "gray32",
       pt.cex = 1.5,
       cex    = 0.9,
       bty    = "n")

legend("bottomright",
       legend = c("Shallow", "Deep"),
       pch    = c(21, 24),
       col    = "gray32",
       pt.bg  = "gray",
       pt.cex = 1.5,
       cex    = 0.9,
       bty    = "n")

dev.off()
