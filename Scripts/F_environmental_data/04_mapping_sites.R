library(maps)
library(mapdata)
library(sp)
library(maptools)
library(corrplot)
library(ggplot2)
library(ncdf4)
library(RColorBrewer)
library(tidync)
library(dplyr)
library(ggnewscale)

# Sampling sites
sampling_sites <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/Metadata/sampling_sites.csv")

# Historical NOAA data
noaa <- readRDS("raster_hist.rds")
noaa_meantemp <- noaa$meanTemp
noaa_meantemp_df <- as.data.frame(noaa_meantemp, xy = TRUE)

# Plot GBR
map1 <- ne_countries(type = "countries", country = "Australia",
                     scale = "medium", returnclass = "sf")

ggplot()+
  geom_tile(data= noaa_meantemp_df, aes(x=x, y=y, fill=meanTemp), size=5) +
  scale_fill_gradientn(limits = c(23,28),
                       na.value = "aliceblue",
                       #colours = c("steelblue3", "cadetblue3", "lightblue1", "lightgoldenrod1", "lightsalmon", "tomato2", "firebrick"))+
                       colours = c("steelblue3", "cadetblue3", "lightblue", "yellowgreen", "firebrick1", "firebrick4"))+
  geom_sf(data = map1, fill = "bisque3")+
  new_scale_fill()+
  geom_point(data=sampling_sites_unique, aes(x=decimalLongitude, decimalLatitude, fill=factor(EcoReefID)), 
             shape = 21, colour = "black", size=4)+
  scale_fill_manual(values = c("#A2B52B", "#7BB52B", "#5CBED1", "#5C9FD1", "#1F7D1E", "#B05102", "#F39237", "#F2C738"))+
  coord_sf(xlim = c(143, 153), ylim = c(-24, -14))+
  labs(fill = "Mean Annual Temperature", x = NULL, y = NULL) +
  theme(panel.background = element_rect(fill = "aliceblue"),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank())

# Plot Heron
geomorphic <- read_sf("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/Habitat/Heron-20260604230741/Geomorphic-Map/geomorphic.geojson")
col_geo=c("#C2B280", "aliceblue", "aliceblue", "#C2B280", "#C2B280", "#C2B280", "#C2B280", "#C2B280", "#C2B280")

sites <- sampling_sites %>%
  filter(EcoReefID == "Heron") %>%
  mutate(zone = case_when(
    str_sub(EcoLocationID_short, -1) == "S" ~ "Shallow",
    str_sub(EcoLocationID_short, -1) == "D" ~ "Deep"))

ggplot() + 
  geom_sf(data = geomorphic, aes(fill = class), lwd = 0, color = NA) + 
  scale_fill_manual(values = col_geo) +
  geom_point(data = sites,
             aes(x = decimalLongitude, y = decimalLatitude, shape = zone),
             size = 2, fill = "white", color = "black", stroke = 0.5) +
  scale_shape_manual(values = c("Shallow" = 21, "Deep" = 24)) +
  annotation_scale(location = "bl", width_hint = 0.3) + 
  theme_void() + 
  theme(legend.position = "none",
        panel.grid = element_blank(),
        plot.background = element_rect(fill = "aliceblue", color = NA),
        panel.background = element_rect(fill = "aliceblue", color = NA))

# Plot Moore
geomorphic <- st_read("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/Habitat/Moore-20230505001246/Geomorphic-Map/geomorphic.geojson")
col_geo=c("#C2B280", "#C2B280", "#C2B280", "aliceblue", "#C2B280", "#C2B280", "#C2B280", "#C2B280", "aliceblue")

sites <- sampling_sites %>%
  filter(EcoReefID == "Moore") %>%
  mutate(zone = case_when(
    str_sub(EcoLocationID_short, -1) == "S" ~ "Shallow",
    str_sub(EcoLocationID_short, -1) == "D" ~ "Deep"))

ggplot() + 
  geom_sf(data = geomorphic, aes(fill = class), lwd = 0, color = NA) + 
  scale_fill_manual(values = col_geo) +
  geom_point(data = sites,
             aes(x = decimalLongitude, y = decimalLatitude, shape = zone),
             size = 2, fill = "white", color = "black", stroke = 0.5) +
  scale_shape_manual(values = c("Shallow" = 21, "Deep" = 24)) +
  annotation_scale(location = "bl", width_hint = 0.3) + 
  theme_void() + 
  theme(legend.position = "none",
        panel.grid = element_blank(),
        plot.background = element_rect(fill = "aliceblue", color = NA),
        panel.background = element_rect(fill = "aliceblue", color = NA))

# Plot Lady Musgrave
geomorphic <- st_read("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/Habitat/LadyM-20230930052240/Geomorphic-Map/geomorphic.geojson")
col_geo=c("#C2B280", "#C2B280", "#C2B280", "#C2B280", "#C2B280", "#C2B280", "aliceblue", "#C2B280", "aliceblue")

sites_ladym <- sampling_sites %>%
  filter(EcoReefID == "LadyMusgrave") %>%
  mutate(zone = case_when(
    str_sub(EcoLocationID_short, -1) == "S" ~ "Shallow",
    str_sub(EcoLocationID_short, -1) == "D" ~ "Deep"))

ggplot() + 
  geom_sf(data = geomorphic, aes(fill = class), lwd = 0, color = NA) + 
  scale_fill_manual(values = col_geo) +
  geom_point(data = sites_ladym,
             aes(x = decimalLongitude, y = decimalLatitude, shape = zone),
             size = 2, fill = "white", color = "black", stroke = 0.5) +
  scale_shape_manual(values = c("Shallow" = 21, "Deep" = 24)) +
  annotation_scale(location = "bl", width_hint = 0.3) + 
  theme_void() + 
  theme(legend.position = "none",
        panel.grid = element_blank(),
        plot.background = element_rect(fill = "aliceblue", color = NA),
        panel.background = element_rect(fill = "aliceblue", color = NA))

# Plot Central
geomorphic <- st_read("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/Habitat/Central-20230504012350/Geomorphic-Map/geomorphic.geojson")
geomorphic$class <- factor(geomorphic$class, levels = c("Reef Crest", "Outer Reef Flat", "Reef Slope", "Sheltered Reef Slope", "Back Reef Slope", "Plateau", "Deep Lagoon", "Inner Reef Flat", "Shallow Lagoon"))
col_geo=c("#C2B280", "#C2B280", "#C2B280", "#C2B280", "#C2B280", "#C2B280", "aliceblue", "#C2B280", "aliceblue")

sites_central <- sampling_sites %>%
  filter(EcoReefID == c("Davies","Chicken","Little Broadhurst")) %>%
  mutate(zone = case_when(
    str_sub(EcoLocationID_short, -1) == "S" ~ "Shallow",
    str_sub(EcoLocationID_short, -1) == "D" ~ "Deep"))

ggplot() + 
  geom_sf(data = geomorphic, aes(fill = class), lwd = 0, color = NA) + 
  scale_fill_manual(values = col_geo) +
  geom_point(data = sites_central,
             aes(x = decimalLongitude, y = decimalLatitude, shape = zone),
             size = 2, fill = "white", color = "black", stroke = 0.5) +
  scale_shape_manual(values = c("Shallow" = 21, "Deep" = 24)) +
  annotation_scale(location = "bl", width_hint = 0.3) + 
  theme_void() + 
  theme(legend.position = "none",
        panel.grid = element_blank(),
        plot.background = element_rect(fill = "aliceblue", color = NA),
        panel.background = element_rect(fill = "aliceblue", color = NA))

# Plot Lizard
geomorphic <- st_read("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/Habitat/Lizard-20260604224501/Geomorphic-Map/geomorphic.geojson")
col_geo=c("#C2B280", "#C2B280", "#C2B280", "#C2B280", "#C2B280", "#C2B280", "aliceblue", "#C2B280", "aliceblue")

sites_central <- sampling_sites %>%
  filter(EcoReefID == c("Lizard")) %>%
  mutate(zone = case_when(
    str_sub(EcoLocationID_short, -1) == "S" ~ "Shallow",
    str_sub(EcoLocationID_short, -1) == "D" ~ "Deep"))

ggplot() + 
  geom_sf(data = geomorphic, aes(fill = class), lwd = 0, color = NA) + 
  scale_fill_manual(values = col_geo) +
  geom_point(data = sites_central,
             aes(x = decimalLongitude, y = decimalLatitude, shape = zone),
             size = 2, fill = "white", color = "black", stroke = 0.5) +
  scale_shape_manual(values = c("Shallow" = 21, "Deep" = 24)) +
  annotation_scale(location = "bl", width_hint = 0.3) + 
  theme_void() + 
  theme(legend.position = "none",
        panel.grid = element_blank(),
        plot.background = element_rect(fill = "aliceblue", color = NA),
        panel.background = element_rect(fill = "aliceblue", color = NA))

# Plot Pelorus
geomorphic <- st_read("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/Habitat/Pelorus-20260604224639/Geomorphic-Map/geomorphic.geojson")
col_geo=c("#C2B280", "#C2B280", "#C2B280", "#C2B280", "#C2B280", "#C2B280", "#C2B280", "aliceblue")

sites_central <- sampling_sites %>%
  filter(EcoReefID == c("Pelorus")) %>%
  mutate(zone = case_when(
    str_sub(EcoLocationID_short, -1) == "S" ~ "Shallow",
    str_sub(EcoLocationID_short, -1) == "D" ~ "Deep"))

ggplot() + 
  geom_sf(data = geomorphic, aes(fill = class), lwd = 0, color = NA) + 
  scale_fill_manual(values = col_geo) +
  geom_point(data = sites_central,
             aes(x = decimalLongitude, y = decimalLatitude, shape = zone),
             size = 2, fill = "white", color = "black", stroke = 0.5) +
  scale_shape_manual(values = c("Shallow" = 21, "Deep" = 24)) +
  annotation_scale(location = "bl", width_hint = 0.3) + 
  theme_void() + 
  theme(legend.position = "none",
        panel.grid = element_blank(),
        plot.background = element_rect(fill = "aliceblue", color = NA),
        panel.background = element_rect(fill = "aliceblue", color = NA))
