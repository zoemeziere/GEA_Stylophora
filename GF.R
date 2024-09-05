library(gradientForest)
library(adespatial)
library(LEA)

# Load previous GF analyses
setwd("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/GEA")
load("gf.RData")

# Data
Y <- read.lfmm("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/outlier_analyses/Spis_noreplicates_badsamples_filtered_prunned_imputed.lfmm")
X <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/environemntal_data/env_data_Spis.csv", header = TRUE)

# Use MEM vectors to correct for pop structure
SpisTaxon1_metadata <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/metadata/WGSpisTaxon1_Metadata.csv")
latlon <- cbind(SpisTaxon1_metadata$decimalLatitude, SpisTaxon1_metadata$decimalLongitude)
dbmem <- dbmem(latlon)
Xnew <- cbind(X[,3:77,drop=F], "MEM1"=dbmem$MEM1, "MEM2"=dbmem$MEM2, "MEM3"=dbmem$MEM3)

# OR use PCA
evec = fread("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/population_structure/Spis_noreplicates_badsamples_prunned.eigenvec")
Xnew <- cbind(X[,3:77,drop=F], "PC1"=evec$PC1, "PC2"=evec$PC2)

preds <- colnames(Xnew)
specs <- colnames(Y)

nSamples <- dim(Y)[1]
nSNPs <- dim(Y)[2]

# Run GF
maxLevel <- floor(log2(nSamples*0.368/2))

gf <- gradientForest(cbind(Xnew,Y), predictor.vars=preds, 
                     response.vars=specs, ntree=10, transform = NULL, 
                     compact=T,nbin=101, maxLevel=maxLevel, trace=T, corr.threshold=0.50)
save(gf,file = "gf.RData")

# bar graphs depicting the importance of each  climate variable
plot(gf, plot.type="Overall.Importance")
plot(gf, plot.type="Cumulative.Importance")

# plot the "turnover functions" showing how allelic composition changes along the environmental gradients
most_important <- names(importance(gf))[1:25]
plot(gf, plot.type = "C", imp.vars = most_important, show.species = F, 
     common.scale = T, cex.axis = 1, cex.lab = 1.2, line.ylab = 1, 
     par.args = list(mgp = c(1.5, 0.5, 0), mar = c(2.5, 2, 2, 2), 
                     omi = c(0.2, 0.3, 0.2, 0.4)))

# plots of turnover functions for individual loci
# Each line within each panel represents allelic change at a single SNP
plot(gf, plot.type = "C", imp.vars = most_important, show.overall = F, legend = T, 
     leg.posn = "topleft", leg.nspecies = 5, cex.lab = 0.7, cex.legend = 0.4, 
     cex.axis = 0.6, line.ylab = 0.9, par.args = list(mgp = c(1.5, 0.5, 0), 
                                                      mar = c(2.5, 1, 0.1, 0.5), 
                                                      omi = c(0, 0.3, 0, 0)))
