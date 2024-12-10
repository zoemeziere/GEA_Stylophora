Rscript - <<EOF

library(vcfR)

gen <- read.vcfR("Spis_noreplicates_badsamples_filtered_linked.vcf")

gen.gt <- extract.gt(gen)
gen.gt.t <- t(gen.gt)

gen.gt.t[gen.gt.t %in% c("0/0")] <- 0
gen.gt.t[gen.gt.t %in% c("0/1")] <- 1
gen.gt.t[gen.gt.t %in% c("1/0")] <- 1
gen.gt.t[gen.gt.t %in% c("1/1")] <- 2

class(gen.gt.t) <- "numeric"

saveRDS(gen.gt.t, "SpisTaxon1_linked.rds")
