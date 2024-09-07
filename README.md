### Scripts and data for preliminary analyses of Whole genome sequence data of Stylophora pistillata Taxon1 corals from the Great Barrier Reef. ###

## Scripts ##

- OutlierAnalyses.R : R script to perform outlier analyses (OutFlank and PCAdapt) on whole dataset to find loci that are more differentiated than 'expected'.
  
- GEA.R : R script to perform GEA analyses (LFMM nad RDA) on whole dataset to find loci that strongly correlated with temperature.
    - Different environemntal datasets can be used (all variables, temperature variables only, PC axes of PCA with temperature variables for example).
    - Population structure can be accounted for using MEM vectors or genomic PC axes for the RDA.

- GF.R : R script to run GradientForest to find enviromnental variables that are the most strongly correlated with genotypes, and get turnover functions. Population structure can be accounted for using MEM vectors or genomic PC axes.

- correlation_coef.sh : Bash script running R script on HPC to calculate Kendall correlation coefficient between Mean Temperature and genotype matrix. This is an example for Offshore Central population, and will be ran on all populations.


## Data ##

- WGSpisTaxon1_Metadata.csv : metadata for all samples
  
- WGSpisTaxon1_OffshoreCentral_Metadata.csv : metadata for Offshore Central population samples only

- env_data_Spis.csv : environemntal data (aquired from erref) for all samples

- env_data_Spis_OC.csv : environemntal data (aquired from erref) for Offshore Central population samples only
  
