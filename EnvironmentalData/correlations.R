library(corrplot)
library(caret)
library(sf)
library(rnaturalearth)

# Create dataset
ecoRRAP_env_data <- read.csv("Relevant_Environmental_data_EcoRRAP_sites.csv", header = TRUE)
SpisTaxon1_metadata <- read.csv("WGSpisTaxon1_Metadata.csv")

merged_data <- merge(SpisTaxon1_metadata, ecoRRAP_env_data, by.x = "EcoLocationID_short", by.y = "Site.code")
merged_data <- merged_data[match(SpisTaxon1_metadata$Samples.renames, merged_data$Samples.renames), ] # make sure same order of individuals

columns_to_remove <- cbind(colnames(SpisTaxon1_metadata)[c(-2, -12)], "lat", "long", "Reef", "Zone", "Site")
merged_data <- merged_data[, !colnames(merged_data) %in% columns_to_remove]

# Load data
X_all <- merged_data

# Get Australian mainland shp file
land <- ne_download(scale = 10, type = "land", category = "physical", returnclass = "sf")
eastern_australia_bbox <- st_bbox(c(xmin = 142, xmax = 155, ymin = -40, ymax = -10), crs = 4326) # crop to eastern australia
eastern_australia <- st_crop(land, eastern_australia_bbox) 
eastern_australia$area <- st_area(eastern_australia) # filter for mainland to avoid island
mainland <- eastern_australia[eastern_australia$area == max(eastern_australia$area), ]
#st_write(mainland, "eastern_australia_mainland.shp")

# Calculate distance to mainland
sites_sf <- st_as_sf(SpisTaxon1_metadata, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)
landDistance <- st_distance(sites_sf, mainland)

X_all$DistanceLand <- as.numeric(landDistance)

# Add depth
X_all$Depth <- as.numeric(SpisTaxon1_metadata$depthOfBottominMeters)

# Remove column for sample names
X_all_env <- X_all[,-2]

# Group env variables at the site level
X_all_env_site1 <- X_all_env %>% 
  distinct(EcoLocationID_short, .keep_all = TRUE)

X_all_env_site <- X_all_env_site1[,-1]

# Investigate correlation among variables at the site level
cor_matrix <- cor(X_all_env_site, method="pearson")

corrplot(cor_matrix, type="upper", tl.pos="td", sig.level=0.05, tl.col="black", font=2, tl.cex=0.6,
         tl.offset=0.7, cl.pos="b", mar=c(0.5,0.5,0.5,0.5), mgp=c(0,0,0), oma=c(0,0,0,0))

# Retain uncorrelated variables (Pearson's coef < 0.7) but keep interest variables
keep_vars <- c("ubedmean", "Turbidity_mean", "DIN_mean", "DIC_mean" , "DIP_mean", "Edmean", 
               "PAR_mean", "omega_ar_mean", "PH_mean", "temp_mean", 
               "Depth", "DistanceLand", "MaxMonthlyMean", "MinMonthlyMean", "MonthlyRange")

cor_threshold <- 0.7
to_remove <- vector("logical", length = ncol(X_all_env_site))

for(i in 1:(ncol(X_all_env_site) - 1)){
  for(j in (i + 1):ncol(X_all_env_site)){
    if(abs(cor_matrix[i, j]) > cor_threshold){
      # Check if both variables are in keep_vars
      if(colnames(X_all_env_site)[i] %in% keep_vars & colnames(X_all_env_site)[j] %in% keep_vars){
        # If both variables are in keep_vars, prompt for manual choice
        cat("Variables", colnames(X_all_env_site)[i], "and", colnames(X_all_env_site)[j], 
            "are highly correlated (", cor_matrix[i, j], "). Choose one to keep:\n")
        choice <- readline(paste("Keep", colnames(X_all_env_site)[i], "(enter 1) or", colnames(X_all_env_site)[j], "(enter 2)? "))
        
        # Mark the chosen variable to keep
        if(choice == "1"){
          to_remove[j] <- TRUE  # Remove the second variable
        } else if(choice == "2"){
          to_remove[i] <- TRUE  # Remove the first variable
        } else {
          cat("Invalid choice, defaulting to removing", colnames(X_all_env_site)[j], "\n")
          to_remove[j] <- TRUE  # Default to removing the second variable
        }
      } else {
        # If only one variable is in keep_vars, automatically keep it
        if(!(colnames(X_all_env_site)[i] %in% keep_vars)){
          to_remove[i] <- TRUE
        } else {
          to_remove[j] <- TRUE
        }
      }
    }
  }
}

X_uncor_env <- X_all_env_site[, !to_remove]
X_uncor_env <- cbind("EcoLocationID_short"=X_all_env_site1[,1], X_uncor_env)

# Merge back to get individual level data
X_uncor_env_ind <- merge(cbind("Samples.renames"=SpisTaxon1_metadata$Samples.renames, "EcoLocationID_short"=SpisTaxon1_metadata$EcoLocationID_short), 
                         X_uncor_env, 
                         by = "EcoLocationID_short")

# Write final dataset of uncorrelated variables
write.csv(X_uncor_env_ind, "env_data_Spis_uncor.csv")

write.csv(X_uncor, "env_data_Spis_uncor.csv")
