library(qvalue)
library(OutFLANK)
library(vcfR)
library(pcadapt)
library(VennDiagram)

setwd("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/outlier_analyses")

#### OutFLANK ####

SpisTaxon1_metadata <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/metadata/WGSpisTaxon1_Metadata.csv")
genotypes.vcf <- read.vcfR("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/vcf_files/Spis_noreplicates_badsamples_filtered_prunned.vcf")
genotypes.gt <- extract.gt(genotypes.vcf)

# transform genotype matriix OutFlank format
G <- genotypes.gt
G[genotypes.gt %in% c("0|0", "0/0")] <- 0
G[genotypes.gt %in% c("0|1", "0/1")] <- 1
G[genotypes.gt %in% c("1|1", "1/1")] <- 2
G[is.na(G)] <- 9
tG <- t(G)

# subsetting populations
subpops <- c("OffshoreCentral","Pelorus", "Lizard", "Moore", "Heron", "LadyMusgrave")
subgen <- tG[SpisTaxon1_metadata$Population%in%subpops,] 
submeta <- subset(SpisTaxon1_metadata,Population%in%subpops)
submeta$Sample_names <- rownames(subgen)

fst <- MakeDiploidFSTMat(subgen,locusNames=1:ncol(subgen),popNames=submeta$Population)
summary(fst$FST)

# check for low sample sizes loci
plot(fst$FST, fst$FSTNoCorr, xlim=c(-0.01,1), ylim=c(-0.01,1), pch=20)
abline(0,1)

# run OutFlank - I set NumberOfSamples=3 here but should use 6 but for some reasone I get an error message with >3
OF <- OutFLANK(fst, LeftTrimFraction=0.05, RightTrimFraction=0.05,
               Hmin=0.1, NumberOfSamples=3, qthreshold=0.05)

OutFLANKResultsPlotter(OF,withOutliers=T,
                       NoCorr=T,Hmin=0.1,binwidth=0.005,
                       Zoom=F, RightZoomFraction=0.05, titletext=NULL)

# find outliers and plot
top_candidates_OF <- OF$results[which(OF$results$qvalues<0.05 & OF$results$He>0.1),]
top_candidates_OF <- OF$results[which(OF$results$qvalues<0.05),] # 84 outliers found

plot(OF$results$LocusName, OF$results$FST, xlab="Position",ylab="FST")
points(top_candidates_OF$LocusName, top_candidates_OF$FST, col="magenta")

# remove low frequency variants
keep_OF <- OF$results[which(OF$results$He>0.1 & !is.na(OF$results$He)),]
plot(keep_OF$LocusName, keep_OF$FST, xlab="Position",ylab="FST")
points(top_candidates_OF$LocusName, top_candidates_OF$FST, col="magenta")

# get SNPs names
loci <- as.data.frame(genotypes.vcf@fix[,1:2])
outlier_loci_OF <- loci[top_candidates_OF$LocusName,]

# export table
outliers_OutFlan <- write_csv(top_can, "/Users/zoemeziere/Desktop/outliers_OutFlan.csv")

#### PCAdapt ####

genotypes <- read.pcadapt("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/vcf_files/Spis_noreplicates_badsamples_filtered_prunned.vcf", type = "vcf")
x <- pcadapt(input = genotypes, K = 20) # start with large K
plot(x, option = "screeplot") # choose K=6 populations

x <- pcadapt(input = genotypes, K = 6)
plot(x , option = "manhattan")
plot(x, option = "qqplot") # the smallest p-values are smaller than expected confirming the presence of outliers
hist(x$pvalues, xlab = "p-values", main = NULL, breaks = 50, col = "orange") #excess of small p-values indicates the presence of outliers

# transform to data frame
mypval <- ldply(x[10], data.frame)
myqval <- qvalue(mypval$X..i..)$qvalues
mydf <- cbind(mypval, myqval)
mydf <- mydf[,c(2,3)]
colnames(mydf) <- c("pval", "qval")
position <- mydf$position <- 1:nrow(mydf) 

top_candidates_PC <- mydf[which(mydf$qval<0.05),] #8081 outliers found

plot(mydf$position, -log10(mydf$qval), xlab="Position", ylab="-log10(q-value)")
points(top_candidates_PC$position, -log10(top_candidates_PC$qval), col="magenta")

# export table
outliers_PCAdapt <- write_csv(as.data.frame(top_candidates_PC), "/Users/zoemeziere/Desktop/outliers_PCAdapt.csv")

# get SNPs names
loci <- as.data.frame(genotypes.vcf@fix[,1:2])
outlier_loci_PCAdapt <- loci[top_candidates_PC$position,]
