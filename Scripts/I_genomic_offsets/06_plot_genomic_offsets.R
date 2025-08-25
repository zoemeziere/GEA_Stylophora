module load r/4.4.2

library(ggplot2)
library(raster)
library(rnaturalearth)
library(rnaturalearthdata)
library(RColorBrewer)
library(vegan)
library(tidyr)

RDA_offset_fut <- readRDS("RDA_offset_fut.rds")

colors <- c("#2e1b42", "#7f3c80", "#9b5fa7" , "#f9e28e", "#f1c40f", "#f39c12", "#e76a2b")
breaks <- quantile(RDA_offset_fut$Global_offset, probs = c(0, 0.1, 0.25, 0.5, 0.75, 0.9, 1))

map1 <- ne_countries(type = "countries", country = "Australia",
                     scale = "medium", returnclass = "sf")

RDA_offset_fut$SSP <- gsub("_.*", "", RDA_offset_fut$SSP_decade)  # Extract the SSP scenario (e.g., "SSP1-2.6")
RDA_offset_fut$Decade <- gsub(".*_", "", RDA_offset_fut$SSP_decade)  # Extract the Decade (e.g., "2050", "2100")

pdf("predict_go_all.pdf")

ggplot(data = RDA_offset_fut) + 
  geom_sf(data = map1, fill="bisque3", size=0) +
  facet_grid(Decade ~ SSP) +
  geom_raster(aes(x = x, y = y, fill = Global_offset)) +
  scale_fill_gradientn(colors = colors) +
  geom_sf(data = map1, fill = "bisque3") +
  coord_sf(xlim = c(142, 153), ylim = c(-25, -10), expand = FALSE) +
  theme_bw(base_size = 8) +
  theme(panel.grid = element_blank(), 
        plot.background = element_blank(), 
        panel.background = element_rect(fill= "aliceblue", color=NA),
        strip.text = element_text(size=11))

dev.off()
