library(vcfR)

# save imputed vcf file data into genotype matrix

gen <- read.vcfR("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/vcf_files/beagle4_Spis_filtered_linked_imp.vcf")

gen.gt <- extract.gt(gen)
gen.gt.t <- t(gen.gt)

gen.gt.t[gen.gt.t %in% c("0|0")] <- 0
gen.gt.t[gen.gt.t %in% c("0|1")] <- 1
gen.gt.t[gen.gt.t %in% c("1|0")] <- 1
gen.gt.t[gen.gt.t %in% c("1|1")] <- 2

class(gen.gt.t) <- "numeric"

saveRDS(gen.gt.t, "/Users/zoemeziere/Documents/PhD/Chapter3_analyses/vcf_files/SpisTaxon1_linked_imputed.rds")