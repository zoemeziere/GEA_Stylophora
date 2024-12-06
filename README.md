# Scripts and data for analyses of whole genome sequence data of Stylophora pistillata Taxon1 corals from the Great Barrier Reef #

## 1 - Repeatability of genomic architecture of local thermal adaptationa cross isolated populations ##

First, we ran GEA analyses for each population (5 populations) separately as well as on the whole dataset: 

    * 00_create_windows.sh - script to create 10kb non overlapping genomic windows across all scaffolds
    
    * 01_AlleleFreqMatrix.sh - script to get allele frequencies (sampling site level) from individual genotypes
    
    * 02_KendallCorrelation.sh - script to calculate Kendall Tau correlation coefficients between allele frequencies and mean temperature for each sampling site
    
    * 03_WZA.sh - script used to apply WZA method from correlation results in genomic windows of 10kb

The above script need the following input files: 

    * A dataframe of site-level temperature data - can be found in PopEnvData folder

    * A dataframe assigning individuals to their sampling site to calculate allele frequencies - can be found in PopMetadata folder, 

    * snp_windows.txt - file containin SNP information (scaffold and position) and windowID (10kb windows)(not included here, too large!)

    * A VCF file - not included here, too large!

From the above scripts, we obtained the following intermediate data files:

    * An allele frequency data dataframe - not included here, too large!

    * A dataframe of Kendall Tau correlations betwen allele frequencies and temperature data - can be found in correlation_results folder

    * A dataframe for WZA results - can be found in WZA_results folder

Then, we used the PicMin method to evalute repeatability of association signals across all 5 popualtions:

    * 04_PicMin.sh - script used to run PicMin across all 5 populations
    * PicMin_results.rds - dataframe of PicMin results

## 2 - RDA analyses to investigate global-scale patterns of nultivariate environmental adaptationin ##

## 3 - Gradient Forest analyses to investigate global-scale patterns of nultivariate environmental adaptationin ##

