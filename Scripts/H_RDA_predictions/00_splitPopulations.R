SpisTaxon1_linked_imputed <- readRDS("SpisTaxon1_linked_imputed.rds")
WGSpisTaxon1_Metadata <- read.csv("WGSpisTaxon1_Metadata.csv")

populations <- unique(WGSpisTaxon1_Metadata.csv$Population)
WGSpisTaxon1_Metadata$Sample_names_gen <- rownames(SpisTaxon1_linked_imputed)

pop_data_list <- lapply(populations, function(pop) { 
individuals_in_pop <- WGSpisTaxon1_Metadata$Sample_names_gen[WGSpisTaxon1_Metadata$Population == pop]
subset_data <- SpisTaxon1_linked_imputed[individuals_in_pop, , drop = FALSE]
return(subset_data) })

saveRDS(pop_data_list[["Heron"]], "Heron_linked_imputed.rds")
saveRDS(pop_data_list[["LadyMusgrave"]], "LadyMusgrave_linked_imputed.rds")
saveRDS(pop_data_list[["Lizard"]], "Lizard_linked_imputed.rds")
saveRDS(pop_data_list[["Moore"]], "Moore_linked_imputed.rds")
saveRDS(pop_data_list[["Pelorus"]], "Pelorus_linked_imputed.rds")
