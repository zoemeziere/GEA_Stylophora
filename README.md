### Scripts and data for preliminary analyses of whole genome sequence data of Stylophora pistillata Taxon1 corals from the Great Barrier Reef. ###

* First, we ran GEA analyses for each population (5 populations) separately - bellow are scripts used for the CentralOffshore population: 

  01_AlleleFreqMatrix.sh - script to get allele frequencies (sampling site level) from individual genotypes

  02_KendallCorrelation.sh - script to calculate Kendall Tau correlation coefficients between allele frequencies and mean temperature for each sampling site

  03_WZA.sh - script used to apply WZA method from correlation results in genomic windows of 10kb

These are the data file needed to run the above scripts only need:

  site_env_data_Heron.csv - Environmental data for each sampling sites for GEA

  Heron_Metadata.csv - Metadata to sort individuals by sampling sites to calculate allele frequencies

  snp_windows.txt - file containin SNP information (scaffold and position) and windowID (10kb windows)(not included here, too large!)

  Spis_ind_Heron_filtered.vcf - VCF file of all individuals (not included here, too large!)

From the above scripts, we obtained the following intermediate data files:

  af_mat.rds - allele frequency data

  site_allele_frqs.rds - allele frequency data

  cor_results.rds - correlation results

  WZA_df.rds - WZA results

* Then, we used the PicMin method to evalute repeatability of association signals across all 5 popualtions:

04_PicMin.sh - script used to run PicMin

The output of the PicMin anlalysis is: picMin_results.rds
