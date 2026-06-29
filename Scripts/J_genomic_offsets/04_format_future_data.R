module load r/4.4.2

library(ggplot2)
library(raster)
library(rnaturalearth)
library(rnaturalearthdata)
library(RColorBrewer)
library(vegan)
library(tidyr)
library(dplyr)

# Load climate change projected data
fut_env <- read.csv("../Future_Data/ensemble_SSP245.csv")

df_long <- fut_env %>%
  gather(key = "date", value = "sst", -reefsUNIQUE_ID) %>%
  mutate(year = as.numeric(substr(date, nchar(date) - 3, nchar(date))),
         month = as.numeric(substr(date, 2, 3)))

# Calculate annual means and ranges
fut_annual_means <- df_long %>%
  group_by(reefsUNIQUE_ID, year) %>%
  summarise(annual_mean = mean(sst, na.rm = TRUE))

fut_monthly_means <- df_long %>%
  group_by(reefsUNIQUE_ID, year, month) %>%
  summarise(monthly_mean = mean(sst, na.rm = TRUE))

fut_annual_ranges <- fut_monthly_means  %>%
  group_by(reefsUNIQUE_ID, year) %>%
  summarise(annual_range = max(monthly_mean, na.rm = TRUE) - min(monthly_mean, na.rm = TRUE))

# Calculate decadal means and ranges
fut_mean_2050 <- fut_annual_means %>%
  filter(year >= 2040 & year <= 2050) %>%
  group_by(reefsUNIQUE_ID) %>%
  summarise(annual_mean_2050 = mean(annual_mean, na.rm = TRUE))

fut_range_2050 <- fut_annual_ranges %>%
  filter(year >= 2040 & year <= 2050) %>%
  group_by(reefsUNIQUE_ID) %>%
  summarise(annual_range_2050 = mean(annual_range, na.rm = TRUE))

# Load historical data to merge by reef ID
hist_env <- read.csv("../Historical_Data/GBR_past_AnnualMean_SST_CRW_5km.csv")
hist_env$mean <- rowMeans(hist_env[,6:45])

fut_mean_2050 <- fut_mean_2050 %>%
  left_join(hist_env %>%  dplyr::select(UNIQUE_ID, LAT, LON), by = c("reefsUNIQUE_ID"="UNIQUE_ID"))

fut_mean_2050 <- na.omit(fut_mean_2050)

fut_range_2050 <- fut_range_2050 %>%
  left_join(hist_env %>%  dplyr::select(UNIQUE_ID, LAT, LON), by = c("reefsUNIQUE_ID"="UNIQUE_ID"))

fut_range_2050 <- na.omit(fut_range_2050)

coordinates(fut_mean_2050) <- ~LON + LAT
proj4string(fut_mean_2050) <- CRS("+proj=longlat +datum=WGS84")

coordinates(fut_range_2050) <- ~LON + LAT
proj4string(fut_range_2050) <- CRS("+proj=longlat +datum=WGS84")

r <- raster(extent(min(fut_mean_2050$LON), max(fut_mean_2050$LON), min(fut_mean_2050$LAT), max(fut_mean_2050$LAT)), resolution = c(0.05, 0.05))

raster_mean <- rasterize(fut_mean_2050, r, field = "annual_mean_2050")
raster_range <- rasterize(fut_range_2050, r, field = "annual_range_2050")

raster_fut <- stack(raster_mean, raster_range)

names(raster_fut) <- c("meanTemp", "rangeTemp")

# Add distance to shore to future raster

library(raster)
library(rnaturalearth)
library(sf)

coords <- coordinates(raster_fut)[!is.na(values(raster_fut[[1]])), ]

land <- ne_countries(scale = "medium", returnclass = "sf")
pts <- st_as_sf(data.frame(coords), coords = c("x","y"), crs = 4326)

dist_to_land <- st_distance(pts, land)
dist_min <- apply(dist_to_land, 1, min)

dist_raster <- raster_fut[[1]]
dist_raster[] <- NA
dist_raster[!is.na(values(raster_fut[[1]]))] <- dist_min

raster_fut <- addLayer(raster_fut, dist_raster)
names(raster_fut)[3] <- "distanceShore"

# Save final raster file

names(raster_fut) <- c("meanTemp", "rangeTemp", "distanceShore")
saveRDS(raster_fut, "raster_fut_SSP245_2050.rds")
