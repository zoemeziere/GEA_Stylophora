module load r/4.4.2

library(ggplot2)
library(raster)
library(dplyr)
library(rnaturalearth)
library(rnaturalearthdata)
library(RColorBrewer)
library(vegan)
library(tidyr)

# Load NOAA historical data GBR wide 
hist_env_mean <- read.csv("GBR_past_AnnualMean_SST_CRW_5km.csv")
hist_env_max <- read.csv("GBR_past_MaxMM_SST_CRW_5km.csv")
hist_env_min <- read.csv("GBR_past_MinMM_SST_CRW_5km.csv")

hist_env <- hist_env_mean[,1:5]

hist_env$meanTemp <- rowMeans(hist_env_mean[,6:45])

hist_env_range <- hist_env_max[,6:45] - hist_env_min[,6:45]
hist_env$rangeTemp <- rowMeans(hist_env_range)

coordinates(hist_env) <- ~LON + LAT
proj4string(hist_env) <- CRS("+proj=longlat +datum=WGS84")

r <- raster(extent(min(hist_env$LON), max(hist_env$LON), min(hist_env$LAT), max(hist_env$LAT)), resolution = c(0.05, 0.05))

raster_hist_env_mean <- rasterize(hist_env, r, field = "meanTemp")
raster_hist_env_range <- rasterize(hist_env, r, field = "rangeTemp")

raster_hist_env <- stack(raster_hist_env_mean, raster_hist_env_range)
names(raster_hist_env) <- c("meanTemp", "rangeTemp")

# Add distance to shore to GBR raster
r <- raster(extent(min(hist_env$LON), max(hist_env$LON), 
                   min(hist_env$LAT), max(hist_env$LAT)), 
            resolution = c(0.05, 0.05),
            crs = CRS("+proj=longlat +datum=WGS84"))

raster_hist_env_mean <- rasterize(hist_env, r, field = "meanTemp")
raster_hist_env_range <- rasterize(hist_env, r, field = "rangeTemp")

raster_hist_env <- stack(raster_hist_env_mean, raster_hist_env_range)
names(raster_hist_env) <- c("meanTemp", "rangeTemp")

raster_hist_proj <- projectRaster(raster_hist, crs = CRS("+init=epsg:3577"))

coastline <- ne_coastline(scale = "medium", returnclass = "sf")
coastline_proj <- st_transform(coastline, crs = crs(raster_hist_proj))

coast_raster <- raster_hist_proj[[1]]    
coast_raster[] <- NA                        
coast_raster <- rasterize(coastline_proj, coast_raster, field = 1)

distance_raster <- distance(coast_raster)

raster_hist_proj <- stack(raster_hist_proj, distance_raster)

names(raster_hist_proj) <- c("meanTemp", "rangeTemp", "distanceShore")
saveRDS(raster_hist_env, "raster_hist.rds")

# Load genotype data
genotypes <- readRDS("Historical_Data/SpisTaxon1_linked_imputed.rds")

# Load NOAA historical data for each genotype
hist_env_gen_mean <- read.csv("Historical_Data/ZOE_SAMPLES_past_AnnualMean_SST_CRW_5km.csv")
hist_env_gen_min <- read.csv("Historical_Data/ZOE_SAMPLES_past_MinMM_SST_CRW_5km.csv")
hist_env_gen_max <- read.csv("Historical_Data/ZOE_SAMPLES_past_MaxMM_SST_CRW_5km.csv")

hist_env_gen_range <- cbind(hist_env_gen_max[,1:7], (hist_env_gen_max[,-c(1:7)] - hist_env_gen_min[,-c(1:7)]))

hist_env_gen_mean <- hist_env_gen_mean %>% arrange(match(Samplesrenames, rownames(genotypes)))
hist_env_gen_range <- hist_env_gen_range %>% arrange(match(Samplesrenames, rownames(genotypes)))

mean_1985_2024 <- rowMeans(hist_env_gen_mean[,8:47])
range_1985_2024 <- rowMeans(hist_env_gen_range[,8:47])

# Load distance to shore for samples
rda_env_ind_unscaled<-read.csv("rda-env_ind_unscaled.csv")
rda_env_ind_unscaled <- rda_env_ind_unscaled %>% arrange(match(Samples.renames, rownames(genotypes)))

hist_env_gen <- cbind(hist_env_gen_mean[,1:7], "meanTemp" = mean_1985_2024, "rangeTemp" = range_1985_2024, "distanceShore"=rda_env_ind_unscaled$dist_to_shore)

hist_env_gen_scaled <- scale(hist_env_gen[,-c(1:7)], center=TRUE, scale=TRUE)
scale_env  <- attr(hist_env_gen_scaled, 'scaled:scale')
center_env <- attr(hist_env_gen_scaled, 'scaled:center')

saveRDS(scale_env, "scale_env.rds")
saveRDS(center_env, "center_env.rds")

hist_env_gen_scaled <- as.data.frame(hist_env_gen_scaled)
saveRDS(hist_env_gen_scaled , "hist_env_gen_scaled.rds")

# Run RDA model - not corrected for population structure
RDA_model <- rda(genotypes ~ ., hist_env_gen_scaled)

saveRDS(RDA_model, "RDA_model.rds")
