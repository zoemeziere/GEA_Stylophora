# calculate distance to shore from GPS coordinates
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)


coordinates<-read.csv("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/environmental_data/ecoRRAP_gps.csv")
sites_sf <- st_as_sf(coordinates, coords = c("long", "lat"), crs = 4326)
coastline <- ne_coastline(scale = "medium", returnclass = "sf")
sites_proj <- st_transform(sites_sf, 3577)
coastline_proj <- st_transform(coastline, 3577)
dist_to_shore <- st_distance(sites_proj, coastline_proj)
min_dist_to_shore <- apply(dist_to_shore, 1, min)

coordinates$dist_to_shore <- as.numeric(min_dist_to_shore)

write.csv(coordinates, "/Users/zoemeziere/Documents/PhD/Chapter3_analyses/environmental_data/ecoRRAP_distance2shore.csv")
