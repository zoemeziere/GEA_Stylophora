#### LFMM ####
library(lfmm)
library(LEA)

setwd("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/outlier_analyses")

ped2lfmm(input.file = "Spis_noreplicates_badsamples_filtered_prunned.ped", 
                      output.file = "Spis_noreplicates_badsamples_filtered_prunned.lfmm", 
                      force = TRUE)

geno_lfmm <- read.lfmm("Spis_noreplicates_badsamples_filtered_prunned.lfmm")

geno_snmf <- snmf("Spis_noreplicates_badsamples_filtered_prunned.lfmm", K=6, repetitions=5, entropy = TRUE)
best = which.min(cross.entropy(geno_snmf, K=6))
impute(geno_snmf, "Spis_noreplicates_badsamples_filtered_prunned.lfmm", method="mode", K=6, run=best)

Y <- read.lfmm("Spis_noreplicates_badsamples_filtered_prunned_imputed.lfmm")
X <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/environemntal_data/env_data_Spis.csv", header = TRUE)
X_std <- decostand(X[,3:77], "standardize")
X_scl <- scale(X_std)

mod_lfmm2 <- lfmm_ridge(Y = Y, X = X_scl[,12], K = 6)

# Test statistics for predictors
pv_lfmm2 = lfmm_test(lfmm = mod_lfmm2, Y = Y, X = X_scl[,12], calibrate="gif")

# GIF and p values
hist(pv_lfmm2$pvalue[,1], main="Unadjusted p-values")        
hist(pv_lfmm2$calibrated.pvalue[,1], main="GIF-adjusted p-values")
zscore <- pv_lfmm2$score[,1] 

# Manually ajust p values using a GIF that gets a better p value distribution (conform to expectations, see Francois et al, 2016)
new.gif1 <- 1.5
adj.pv1 <- pchisq(zscore^2/new.gif1, df=1, lower = FALSE)
hist(adj.pv1, main="REadjusted p-values (GIF=1.5)")
pv_lfmm2$calibrated.pvalue[,1] <- adj.pv1

# Convert p values to q values
pv_lfmm2.qv <- qvalue(pv_lfmm2$calibrated.pvalue)$qvalues

# Candidate SNPs with FDR 5%
# A q-value threshold of 0.05 yields a FDR of 5%
pv_lfmm2.FDR.1 <- which(pv_lfmm2.qv < 0.05) # 8,063 SNPs

# Plot
plot(-log10(pv_lfmm2.qv), cex = .3, xlab = "Locus",  ylab = "-Log(Q)", col = "blue")
abline(h= -log10(0.05))
points(pv_lfmm2.FDR.1, -log10(pv_lfmm2.qv)[pv_lfmm2.FDR.1], cex = .3, col = "brown") # Candidate loci at FDR level

#### RDA ####
library(vegan) 
library(adespatial)
library(LEA)
library(ggplot2)

# Calculating MEM vectors
SpisTaxon1_metadata <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/metadata/WGSpisTaxon1_Metadata.csv")
latlon <- cbind(SpisTaxon1_metadata$decimalLatitude, SpisTaxon1_metadata$decimalLongitude)

# Use MEM vectors
dbmem <- dbmem(latlon)
# OR PC axes
evec = fread("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/population_structure/Spis_noreplicates_badsamples_prunned.eigenvec")

# Input environmental and spatial data
X <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/environemntal_data/env_data_Spis.csv", header = TRUE)

# Use MEM vectors
Xnew <- cbind(X[,3:77,drop=F], "MEM1"=dbmem$MEM1, "MEM2"=dbmem$MEM2, "MEM3"=dbmem$MEM3)
# OR PC axes
Xnew <- cbind(X[,3:77,drop=F], "PC1"=evec$PC1, "PC2"=evec$PC2)

Xnew_std <- cbind(decostand(Xnew[,1:75], "standardize"), "PC1"=Xnew$PC1, "PC2"=Xnew$PC2)

# Input genotypes imputed using LEA
Y <- read.lfmm("Spis_noreplicates_badsamples_filtered_prunned_imputed.lfmm")
Y.rda <- as.data.frame(Y)

# Run partial RDA correcting for geography
rda <- rda(Y.rda[] ~ Xnew_std$temp_mean + Xnew_std$temp_daily_range + Condition(Xnew_std$PC1+Xnew_std$PC2), scale=T)

# Get stats
RsquareAdj(rda)
summary(eigenvals(rda, model = "constrained"))
signif.full <- anova.cca(rda, parallel=getOption("mc.cores"))
signif.axis <- anova.cca(rda, by="axis", parallel=getOption("mc.cores"))
vif.cca(rda)

# Plot
ii=summary(rda)
st=as.data.frame(ii$sites[,1:2])
sp=as.data.frame(ii$species[,1:2])
yz=as.data.frame(ii$biplot[,1:2])

ggplot() +
  geom_point(data = st,aes(RDA1,RDA2, col = SpisTaxon1_metadata$Population, shape= SpisTaxon1_metadata$EcoZoneID), size=3) +
  scale_colour_manual(values = c("#ff7f00","#1f78b4","#ffff33","#a6cee3","#33a02c","#e31a1c")) +
  geom_point(data = sp,aes(RDA1,RDA2),size=6, shape=19, colour = "grey") +
  geom_segment(data = yz,aes(x = 0, y = 0, xend = RDA1, yend = RDA2), 
               arrow = arrow(length = unit(0.1,"cm"), type = "open"),linetype=1, size=0.6) +
  geom_text(data = yz,aes(RDA1,RDA2,label=row.names(yz)), position = position_nudge(y = 0.1), size=1) +
  labs(x=paste("RDA1 (", format(100 *ii$cont[[1]][2,1], digits=3), "%)", sep=""),
       y=paste("RDA2 (", format(100 *ii$cont[[1]][2,2], digits=3), "%)", sep="")) +
  geom_hline(yintercept=0,linetype=3,size=0.5) + 
  geom_vline(xintercept=0,linetype=3,size=0.5) +
  theme_bw() +
  theme(axis.text=element_text(size=10), axis.title=element_text(size=10))
