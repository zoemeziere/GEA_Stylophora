## Playing around with RDA options using reduced data set

#library(tidyverse)
library(vegan)

# Set paths and load data
local_path<-getwd()
setwd(local_path)

genotypes<-readRDS("SpisTaxon1_linked_imputed_1000snps.rds") #230 individuals, 1000 SNPs but includes missing data

# TODO:
# for now, impute by using mean value -> this needs to be changed!

# in genotypes, replace NA values with column mean value 
genotypes_imputed<-genotypes
genotypes_imputed[is.na(genotypes_imputed)] <- colMeans(genotypes_imputed, na.rm = TRUE)[col(genotypes_imputed)]

env<-read.csv("../EnvironmentalData/env_data_Spis_uncor.csv")
env2 <- as.matrix(env[,-1]) # remove first column (ID) and turn into matrix for RDA


metadata<-read.csv("WGSpisTaxon1_Metadata.csv") #49 lat long combos


# global RDA - emulating calls in RDA_global.sh
global.rda <- rda(genotypes_imputed ~ env2, scale=T)
summary(global.rda) # observing that only RDA1 & RDA2 explain more variance than PC1

# global RDA with lat and long included - add lat and long in to env3
env3<-env2
env3 <- cbind(env3, decimalLatitude = metadata$decimalLatitude)
env3 <- cbind(env3, decimalLongitude = metadata$decimalLongitude)

# redo rda
global_latlong.rda <- rda(genotypes_imputed ~ env3, scale=T)
summary(global_latlong.rda) # not that much better! but it's only 1000 loci..


# Because the grid sizes exceed our sampling size (=individual) we should be adding a random effect 
# to deal with grid sizes for spatial data 
# I am going to hack the grid identity 



