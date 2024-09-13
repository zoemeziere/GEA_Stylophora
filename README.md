### Scripts and data for preliminary analyses of Whole genome sequence data of Stylophora pistillata Taxon1 corals from the Great Barrier Reef. ###

## Scripts ##

- OutlierAnalyses.R : R script to perform outlier analyses (OutFlank and PCAdapt) on whole dataset to find loci that are more differentiated than 'expected'.
  
- GEA.R : R script to perform GEA analyses (LFMM nad RDA) on whole dataset to find loci that strongly correlated with temperature.
    - Different environemntal datasets can be used (all variables, temperature variables only, PC axes of PCA with temperature variables for example).
    - Population structure can be accounted for using MEM vectors or genomic PC axes for the RDA.

- GF.R : R script to run GradientForest to find enviromnental variables that are the most strongly correlated with genotypes, and get turnover functions. Population structure can be accounted for using MEM vectors or genomic PC axes.

- correlation_coef.sh : Bash script running R script on HPC to calculate Kendall correlation coefficient between Mean Temperature and genotype matrix. This is an example for Offshore Central population, and can be ran on each populations.

- correlation_coef.R : R script to analyse output from correlation_coef.sh.


## Metadata ##

- WGSpisTaxon1_Metadata.csv : metadata for all samples
  
- WGSpisTaxon1_OffshoreCentral_Metadata.csv : metadata for Offshore Central population samples only


## Env_Data ##

Environemntal data (aquired from erref) for the whole dataset as well as for each popualtion.

## VCFs_shuf ##

VCF files for each popualations dowsampled to 100,000 randomly selected SNPs (out for ~ 5.7 million). No missing data.
WARNINGS: 
1) Not the same 100,000 randomly selected SNPs for each popualation - so I dont expect to find any strong signals - this is just to play around with and get the scripts working.
2) Could not upload the VCF file for the OffshoreCentral popualtiona as it is too large.
  
