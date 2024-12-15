## Playing around with RDA options using reduced data set

#library(tidyverse)
library(vegan)

# Set paths and load data
local_path<-getwd()
setwd(local_path)

## TODO - add manual scaling so that prediction works fine

# Read in files -----------------------------------------------------------

genotypes<-readRDS("SpisTaxon1_linked_imputed_1000snps.rds") #230 individuals, 1000 SNPs but includes missing data

# TODO:
# for now, impute by using mean value -> this needs to be changed to better genotypic imputation!

# in genotypes, replace NA values with column mean value 
genotypes_imputed<-genotypes
# Replace NA values in each column with the column mean
for (i in seq_len(ncol(genotypes_imputed))) {
  genotypes_imputed[is.na(genotypes_imputed[, i]), i] <- mean(genotypes_imputed[, i], na.rm = TRUE)
}

# read in environment 
env<-read.csv("../EnvironmentalData/env_data_Spis_uncor.csv")
env2 <- as.matrix(env[,-1]) # remove first column (ID) and turn into matrix for RDA


metadata<-read.csv("WGSpisTaxon1_Metadata.csv") #49 lat long combos


# Simple global RDA -------------------------------------------------------


# global RDA - emulating calls in RDA_global.sh
global.rda <- rda(genotypes_imputed ~ env2, scale=T)
summary(global.rda) # observing that only RDA1 & RDA2 explain more variance than PC1



# Global RDA with lat and long  -------------------------------------------


# global RDA with lat and long included - add lat and long in to env3
env3<-env2
env3 <- cbind(env3, decimalLatitude = metadata$decimalLatitude)
env3 <- cbind(env3, decimalLongitude = metadata$decimalLongitude)

# redo rda
global_latlong.rda <- rda(genotypes_imputed ~ env3, scale=T)
summary(global_latlong.rda) # not that much better! but it's only 1000 loci..




# Exploring grid blocks in data  ------------------------------------------


# Because the grid sizes exceed our sampling size (=individual) we should be adding a random effect 
# to deal with grid sizes for spatial data 
# I am going to hack the grid identity 
# Convert the matrix to a data frame for this operation
env4_df <- as.data.frame(env2)

# Select all columns except Depth and DistanceLand
cols_to_consider <- setdiff(colnames(env4_df), c("Depth", "DistanceLand"))

# Create a factor based on identical rows
site_factor <- as.factor(apply(env4_df[, cols_to_consider, drop = FALSE], 1, paste, collapse = "_"))

# Replace factor names with integers
site_factor_int <- as.integer(site_factor)

# Add the integer factor to env4_df
env4_df$site_factor_int <- site_factor_int

# Create a table showing the count of each integer factor
factor_count_table <- table(site_factor_int)

# Print the table
print(factor_count_table) # 46 unique sites - this is good!


# Lets see how many sites we have by regions
# Create a data frame combining the integer factor and EcoClusterID
combined_data <- data.frame(site_factor_int, EcoClusterID = metadata$EcoClusterID)

# Split the data by EcoClusterID
split_data <- split(combined_data, combined_data$EcoClusterID)

# Function to create a subtable for each EcoClusterID
create_subtable <- function(data) {
  table(data$site_factor_int)
}

# Apply the function to each subset and store the result in a list
subtables <- lapply(split_data, create_subtable)

# Print subtables
for (ecocluster_id in names(subtables)) {
  cat("EcoClusterID:", ecocluster_id, "\n")
  print(subtables[[ecocluster_id]])
  cat("\n")
}

# We should be good for Offshore Central GBR and Offshore North GBR and maybe Offshore South GBR 

# Add the site factor to the data frame - just for reference
env4_df <- cbind(env4_df, site_factor)

# global RDA with blocks for pseudo replication ---------------------------

# turn env back into a matrix to prep for RDA
env4 <- as.matrix(env4_df)




# RDA with blocks 
global_block.rda <- rda(genotypes_imputed ~ env4 + Condition(site_factor), scale=T)

global_block.rda 

# What is happening here? I suspect the previous selection of values was based on looking 
# at environmental values by individuals... however this means that some sites are counted more
# than once. Environmental correlations should be re-assessed based on grid identity. 

# I am going to ignore this for now ... 

# We are primarily concerned with the structure of the model and not testing significance...
# however, if we did want to test significance, we can follow guidelines from 
#  https://fromthebottomoftheheap.net/2014/11/03/randomized-complete-block-designs-and-vegan/
#  see Example_block_design_RDA.R 
#  The design permutation is not applicable to our situation b/c we are not interested 
#  in testing whether there are differences among individuals within blocks.
#  We are interested in the overall structure of the model and can use the 
# Model based permutation = permutation of residuals after covariables have been accounted in the model

#h <- how(blocks = site_factor, nperm = 999)
#setBlocks(h) <- NULL   
h <- how(blocks = NULL, nperm = 99) # would likely increase perms for real thing
signif_gblock_rda <- anova(global_block.rda, permutations = h)
signif_gblock_rda

# can look at signif of RDA axes
signif_axis_gblock_rda <- anova(global_block.rda, permutations = h,  by = "axis")

# or variables in env
signif_axis_gblock_rda <- anova(global_block.rda, permutations = h,  by = "terms")


## But back to the rda model....
str(global_block.rda)

# predicted values from the model
u_scores<-global_block.rda$CCA$u


# Make a local model and apply to a different region ----------------------
# we will make a model for Offshore Central GBR and apply to Offshore North GBR

# Model for Offshore Central GBR
# Using metadata$EcoClusterID, identify rows that are Offshore Central GBR
offshore_central_gbr <- metadata$EcoClusterID == "Offshore Central GBR"
offshore_north_gbr <- metadata$EcoClusterID == "Offshore North GBR"

# subset genotypes_imputed, env4, and site_factor  to only include Offshore Central GBR
genotypes_offshore_central_gbr <- genotypes_imputed[offshore_central_gbr, ]
site_factor_offshore_central_gbr <- site_factor[offshore_central_gbr]
env4_offshore_central_gbr <- env4[offshore_central_gbr, ]

# check dimensions
isTRUE(nrow(genotypes_offshore_central_gbr) == nrow(env4_offshore_central_gbr))
isTRUE(nrow(genotypes_offshore_central_gbr) == length(site_factor_offshore_central_gbr))

# local RDA model for Offshore Central GBR
local_block_offshore_central_gbr <- rda(genotypes_offshore_central_gbr 
              ~ env4_offshore_central_gbr + Condition(site_factor_offshore_central_gbr), 
              scale=T)

#(ignoring warnings)

u_scores_offshore_central_gbroff<- local_block_offshore_central_gbr$CCA$u


# Model for Offshore North GBR
# subset genotypes_imputed, env4, and site_factor  to only include Offshore North GBR
genotypes_offshore_north_gbr <- genotypes_imputed[offshore_north_gbr, ]
site_factor_offshore_north_gbr <- site_factor[offshore_north_gbr]
env4_offshore_north_gbr <- env4[offshore_north_gbr, ]

# check dimensions
isTRUE(nrow(genotypes_offshore_north_gbr) == nrow(env4_offshore_north_gbr))
isTRUE(nrow(genotypes_offshore_north_gbr) == length(site_factor_offshore_north_gbr))

# local RDA model for Offshore North GBR
local_block_offshore_north_gbr <- rda(genotypes_offshore_north_gbr 
              ~ env4_offshore_north_gbr + Condition(site_factor_offshore_north_gbr), 
              scale=T)


local_block_offshore_north_gbr 

## IN PROGRESS
## prediction 
# predict for Offshore Central GBR using model from Offshore North GBR

test<-predict(local_block_offshore_north_gbr,  #model to use 
              newdata=genotypes_offshore_central_gbr,  #apply the model to these data
              type="lc")


predict(object, newdata, type = c("response", "wa", "sp", "lc", "working"),
        rank = "full", model = c("CCA", "CA"), scaling = "none",
        correlation = FALSE, ...)

data(dune)
data(dune.env)
mod <- cca(dune ~ A1 + Management + Condition(Moisture), data=dune.env)
# Definition of the concepts 'fitted' and 'residuals'
mod
cca(fitted(mod))
cca(residuals(mod))
# Remove rare species (freq==1) from 'cca' and find their scores
# 'passively'.
freq <- specnumber(dune, MARGIN=2)
freq
mod <- cca(dune[, freq>1] ~ A1 + Management + Condition(Moisture), dune.env)
predict(mod, type="sp", newdata=dune[, freq==1], scaling=2)
# New sites
predict(mod, type="lc", new=data.frame(A1 = 3, Management="NM", Moisture="2"), scal=2)
# Calibration and residual plot
mod <- cca(dune ~ A1 + Moisture, dune.env)
pred <- calibrate(mod)
pred
with(dune.env, plot(A1, pred[,"A1"] - A1, ylab="Prediction Error"))
abline(h=0)
