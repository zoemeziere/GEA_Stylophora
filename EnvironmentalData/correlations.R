library(corrplot)
library(caret)
library(ggOceanMaps)
library(sf)

# Load data
X_all <- read.csv("env_data_Spis.csv", header = TRUE)
SpisTaxon1_metadata <- read.csv("WGSpisTaxon1_Metadata.csv")

# Get Australian mainland shp file
land <- ne_download(scale = 10, type = "land", category = "physical", returnclass = "sf")
eastern_australia_bbox <- st_bbox(c(xmin = 142, xmax = 155, ymin = -40, ymax = -10), crs = 4326) # crop to eastern australia
eastern_australia <- st_crop(land, eastern_australia_bbox) 
eastern_australia$area <- st_area(eastern_australia) # filter for mainland to avoid island
mainland <- eastern_australia[eastern_australia$area == max(eastern_australia$area), ]
st_write(mainland, "eastern_australia_mainland.shp")

# Calculate distance to mainland
sites_sf <- st_as_sf(SpisTaxon1_metadata, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)
landDistance <- st_distance(sites_sf, mainland)

X_all$DistanceLand <- as.numeric(landDistance)

# Remove column for sample names
X_all_env <- X_all[,-1]

# Investigate correlation among variables
cor_matrix <- cor(X_all_env, method="pearson")

corrplot(cor_matrix, type="upper", tl.pos="td", sig.level=0.05, tl.col="black", font=2, tl.cex=0.6,
         tl.offset=0.7, cl.pos="b", mar=c(0.5,0.5,0.5,0.5), mgp=c(0,0,0), oma=c(0,0,0,0))

# Retain uncorrelated variables (Pearson's coef < 0.7) but keep interest variables
keep_vars <- c("temp_daily_range", "temp_mean", "EpiPAR_sg_mean", "Secchi_mean", 
               "PH_mean", "speed_mean", "Depth", "DistanceLand")
cor_threshold <- 0.7
to_remove <- vector("logical", length = ncol(X_all_env))

for(i in 1:(ncol(X_all_env) - 1)){
  for(j in (i + 1):ncol(X_all_env)){
    if(abs(cor_matrix[i, j]) > cor_threshold){
      # Check if both variables are in keep_vars
      if(colnames(X_all_env)[i] %in% keep_vars & colnames(X_all_env)[j] %in% keep_vars){
        # If both variables are in keep_vars, prompt for manual choice
        cat("Variables", colnames(X_all_env)[i], "and", colnames(X_all_env)[j], 
            "are highly correlated (", cor_matrix[i, j], "). Choose one to keep:\n")
        choice <- readline(paste("Keep", colnames(X_all_env)[i], "(enter 1) or", colnames(X_all_env)[j], "(enter 2)? "))
        
        # Mark the chosen variable to keep
        if(choice == "1"){
          to_remove[j] <- TRUE  # Remove the second variable
        } else if(choice == "2"){
          to_remove[i] <- TRUE  # Remove the first variable
        } else {
          cat("Invalid choice, defaulting to removing", colnames(X_all_env)[j], "\n")
          to_remove[j] <- TRUE  # Default to removing the second variable
        }
      } else {
        # If only one variable is in keep_vars, automatically keep it
        if(!(colnames(X_all_env)[i] %in% keep_vars)){
          to_remove[i] <- TRUE
        } else {
          to_remove[j] <- TRUE
        }
      }
    }
  }
}

X_uncor_env <- X_all_env[, !to_remove]
X_uncor <- cbind("Sample_names"=X_all$Sample_names, X_uncor_env)
write.csv(X_uncor, "env_data_Spis_uncor.csv")
