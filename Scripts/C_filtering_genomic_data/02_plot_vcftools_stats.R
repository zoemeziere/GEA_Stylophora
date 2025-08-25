library(tidyverse)

setwd("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/vcftools_stats")

#variant quality
#a minimum threshold of 30 is recommended (1 in 1000 chance that SNP call is erroneous)
var_qual <- read_delim("./genotype_genomicDBI_Spis_gather.lqual", delim = "\t",
                       col_names = c("chr", "pos", "qual"), skip = 1)

ggplot(var_qual, aes(qual)) + 
  geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3) + 
  theme_light() +
  xlim(0,1000)

summary(var_qual$qual)

#variant mean depth
#recommended to set maximum read depth at mean depth x 2
var_depth <- read_delim("./genotype_genomicDBI_Spis_gather.ldepth.mean", delim = "\t",
                        col_names = c("chr", "pos", "mean_depth", "var_depth"), skip = 1)

ggplot(var_depth, aes(mean_depth)) +
  geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3) + 
  xlim(0, 100) +
  theme_light()

summary(var_depth$mean_depth)

#variant missingness
#usually between 0.75-0.95 is used - between 5 and 25% missing data allowed
var_miss <- read_delim("./genotype_genomicDBI_Spis_gather.lmiss", delim = "\t",
                       col_names = c("chr", "pos", "nchr", "nfiltered", "nmiss", "fmiss"), skip = 1)

ggplot(var_miss, aes(fmiss)) +
  geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3) +
  theme_light() + 
  xlim(0,0.02)

summary(var_miss$fmiss)

#minor allele frequency
#good to have one dataset with hard MAF filtering and one without MAF filtering
var_freq <- read_delim("./genotype_genomicDBI_Spis_gather.frq", delim = "\t",
                       col_names = c("chr", "pos", "nalleles", "nchr", "a1", "a2"), skip = 1)

var_freq$maf <- var_freq %>% select(a1, a2) %>% apply(1, function(z) min(z))

ggplot(var_freq, aes(maf)) +
  geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3) +
  theme_light()

summary(var_freq$maf)

#mean depth per individual
#lookout for outliers
ind_depth <- read_delim("./genotype_genomicDBI_Spis_gather.idepth", delim = "\t",
                        col_names = c("ind", "nsites", "depth"), skip = 1)

ggplot(ind_depth, aes(depth)) +
  geom_histogram(fill = "dodgerblue1", colour = "black", alpha = 0.3) +
  theme_light()

#proportion of missing data per individual
#make sure there are no outliers and missing data small (eg. 0.01-0.2)
ind_miss  <- read_delim("./genotype_genomicDBI_Spis_gather.imiss", delim = "\t",
                        col_names = c("ind", "ndata", "nfiltered", "nmiss", "fmiss"), skip = 1)

ggplot(ind_miss, aes(fmiss)) + 
  geom_histogram(fill = "dodgerblue1", colour = "black", alpha = 0.3) +
  theme_light()

#heterozygosity and inbreeding per individual
#lookout for signs of allelic dropout (strong negative F) or DNA contaminaion (srong positive F)
ind_het <- read_delim("./genotype_genomicDBI_Spis_gather.het", delim = "\t",
                      col_names = c("ind","ho", "he", "nsites", "f"), skip = 1)

ggplot(ind_het, aes(he)) +
  geom_histogram(fill = "dodgerblue1", colour = "black", alpha = 0.3) +
  theme_light()
