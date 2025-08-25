# Get eReef data for LocationID sites

library(RNetCDF)
library(lubridate)
library(tidyverse)
library(ncdf4)

site_coordinates <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/environmental_data/ecoRRAP_gps.csv")
input_file <- "https://thredds.ereefs.aims.gov.au/thredds/dodsC/gbr1_2.0/monthly.nc"

time <- var.get.nc((open.nc(input_file)), "time") 
as_date(time[1], origin="1990-01-01 00:00:00 +10") 
as_date(time[length(time)], origin="1990-01-01 00:00:00 +10") 

start_time_index <- 2 
count_time_index <- 108 # from 01-2015 to 12-2023

server_file_i <- open.nc(input_file)
server_lons_i <- var.get.nc(server_file_i, "longitude")
server_lats_i <- var.get.nc(server_file_i, "latitude")

variables <- c("temp")
v=1

site_coordinates<- site_coordinates |>
  mutate(eReefs_k = NA) |>
  mutate(eReefs_k = ifelse(Zone == "S", 14, eReefs_k)) |>
  mutate(eReefs_k = ifelse(Zone == "D", 12, eReefs_k)) |>
  mutate(eReefs_k = ifelse(Zone == "F", 16, eReefs_k))

site_coordinates$temp_mean = NA
site_coordinates$temp_monthly_max = NA
site_coordinates$temp_monthly_min = NA
site_coordinates$temp_monthly_range = NA

for(j in which(is.na(site_coordinates$temp_mean) == TRUE)) {
  t_start = Sys.time()
  lon_j <- site_coordinates[j,]$long
  lat_j <- site_coordinates[j,]$lat
  lon_index <- which.min(abs(server_lons_i - lon_j))
  lat_index <- which.min(abs(server_lats_i - lat_j))
  k_index <- site_coordinates[j,]$eReefs_k
  start_j <- c(lon_index, lat_index, k_index, start_time_index)
  count_j <- c(1, 1, 1, count_time_index)
  temp_j <- var.get.nc(server_file_i, "temp", start_j, count_j)
  dates <- seq(as.Date("2015-01-01"), by = "month", length.out = length(temp_j))
  temp_data <- data.frame(date = dates, temp = temp_j)
  temp_data$year <- format(temp_data$date, "%Y")
  yearly_max <- temp_data %>% group_by(year) %>% summarize(max_monthly_mean = max(temp, na.rm = TRUE), .groups = "drop")
  yearly_min <- temp_data %>% group_by(year) %>% summarize(min_monthly_mean = min(temp, na.rm = TRUE), .groups = "drop")
  temp_monthly_mean <- mean(temp_data$temp, na.rm = TRUE)
  temp_monthly_max <- mean(yearly_max$max_monthly_mean, na.rm = TRUE)
  temp_monthly_min <- mean(yearly_min$min_monthly_mean, na.rm = TRUE)
  temp_monthly_range <- mean(yearly_max$max_monthly_mean - yearly_min$min_monthly_mean, na.rm = TRUE)
  site_coordinates[j, "temp_mean"] <- temp_monthly_mean
  site_coordinates[j, "temp_monthly_max"] <- temp_monthly_max
  site_coordinates[j, "temp_monthly_min"] <- temp_monthly_min
  site_coordinates[j, "temp_monthly_range"] <- temp_monthly_range
  cat(paste("Row #"), j, Sys.time()-t_start, "\n")
}

write.csv(site_coordinates, "site_temp.csv")

##### Get temp variables using monthly data for entire GBR ####
input_file <- "https://thredds.ereefs.aims.gov.au/thredds/dodsC/gbr1_2.0/monthly.nc"
monthly_temp <- open.nc(input_file)

lon <- var.get.nc(monthly_temp, "longitude")
lat <- var.get.nc(monthly_temp, "latitude")
temp_var <- "temp" 

start_time_index <- 2
count_time_index <- 73

current <- 0
total <- length(lon) * length(lat)
results <- data.frame()

chunk_size <- 100

results <- vector("list", length(lon) * length(lat))
idx <- 1
for (lon_idx in seq_along(lon)) {
  for (lat_idx in seq_along(lat)) {
    cat(sprintf("\rProcessing %d out of %d (%.2f%% complete)", idx, total, idx / total * 100))
    flush.console()
    start <- c(lon_idx, lat_idx, 13, start_time_index)
    count <- c(1, 1, 1, chunk_size)
    temp_data <- var.get.nc(monthly_temp, temp_var, start = start, count = count)
    for (t_idx in start_time_index:(start_time_index + count_time_index - 1)) {
      temp_data_chunk <- var.get.nc(monthly_temp, temp_var, start = c(lon_idx, lat_idx, 13, t_idx), count = c(1, 1, 1, 1))
      mean_temp <- mean(temp_data_chunk, na.rm = TRUE)
      results[[idx]] <- c(longitude = lon[lon_idx], latitude = lat[lat_idx], mean_temperature = mean_temp)
      idx <- idx + 1
    }
  }
}

# save as raster
gbr_MeanTemp_raster <- results |>
  t() |>   # transpose temps matrix
  raster(  # create raster
    xmn = min(lon), xmx = max(lon), 
    ymn = min(lat), ymx = max(lat), 
    crs = CRS("+init=epsg:4326")
  ) |>
  flip(direction = 'y') # flip the raster

writeRaster(
  x = gbr_MeanTemp_raster, # what to save
  filename = "gbr_MeanTemp_raster.nc", # where to save it
  format = "CDF", # what format to save it as
  overwrite = TRUE # whether to replace any existing file with the same name
)

# plot
gbr_MeanTemp_raster <- raster("gbr_MeanTemp_raster.nc")
plot(gbr_MeanTemp_raster)