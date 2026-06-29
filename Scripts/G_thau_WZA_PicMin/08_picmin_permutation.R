args <- commandArgs(trailingOnly = TRUE)
perm <- as.numeric(args[1])

# PicMin functions

library(poolr)

orderStatsPValues <- function(p_list){
  ## This function returns a list of the p-values for each of marginal p-values
  # sort the list of $p$-values
  p_sort <- sort(p_list)[2:length(p_list)]
  # calculate the number of species minus 1 
  n = length(p_sort)
  # get a vector of the 'a' parameters for each of the marginal distributions
  the_as = 1:length(p_sort)
  # get a vector of the 'b' parameters for each of the marginal distributions
  the_bs = n+1-the_as
  # calculate the p-values for each of the marginals and return
  return(pbeta(p_sort, the_as, the_bs))
}

PicMin <- function(pList, correlationMatrix, numReps = 100000){
  # Calculate the p-value for the order statistics
  ord_stats_p_values <- orderStatsPValues(pList)
  # Apply the Tippett/Dunn-Sidak Correction
  p_value <- tippett(ord_stats_p_values, adjust = "empirical", 
                     R = correlationMatrix, 
                     side = 1, 
                     #                     size = numReps,
                     size = c(1000, 10000, 1000000), threshold = c(.10, .01))$p
  return(list(p=p_value,
              config_est=which.min(ord_stats_p_values)+1))
}

GenerateNullData <- function(adaptation_screen, a, b, n, genes){
  temp <- c( rbeta(1,a,b),replicate(n-1, sample(genes,1)/genes) ) 
  while (sum(temp<adaptation_screen)==0){
    temp <- c( rbeta(1,a,b),replicate(n-1, sample(genes,1)/genes) ) 
  }
  return(temp)
}

empirical_ps <- function( vector_of_values ){
  1-rank(vector_of_values)/length(vector_of_values)
}

get_names <- function( lineage_df ){
  return( paste( lineage_df$scaff, lineage_df$start,
                 sep = "_") )
}

min_pop <- function(population_df, population_name){
  tmp <- data.frame(emp_p = population_df$emp_p,
                    win_id = population_df$gene)
  names(tmp) <- c(population_name, "win_id")
  return(tmp)
}

Moore <- readRDS("Moore_WZA.rds")
Lizard <- readRDS("Lizard_WZA.rds")
Pelorus <- readRDS("Pelorus_WZA.rds")
CentralOffshore <- readRDS("CentralOffshore_WZA.rds")
Heron <- readRDS("Heron_WZA.rds")

# Calculate p values from WZA score

Moore$emp_p <- empirical_ps(abs(Moore$Z))
Lizard$emp_p <- empirical_ps(abs(Lizard$Z))
Pelorus$emp_p <- empirical_ps(abs(Pelorus$Z))
CentralOffshore$emp_p <- empirical_ps(abs(CentralOffshore$Z))
Heron$emp_p <- empirical_ps(abs(Heron$Z))

# Minimise dataframes

Moore_m <- min_pop(Moore, "Moore")
Lizard_m <- min_pop(Lizard, "Lizard")
Pelorus_m <- min_pop(Pelorus, "Pelorus")
CentralOffshore_m <- min_pop(CentralOffshore, "CentralOffshore")
Heron_m <- min_pop(Heron, "Heron")

# Combine data frames for each population

df_list <- list(Moore_m, Lizard_m, Pelorus_m, CentralOffshore_m, Heron_m)
all_pops <- Reduce(function(x, y) merge(x, y, by = "win_id", all = TRUE), df_list)
all_pops_p <- all_pops[, !(names(all_pops) %in% c("win_id"))]
rownames(all_pops_p) <- all_pops$win_id

# Permutation

permuted_pops <- as.data.frame(apply(all_pops_p, 2, function(col) {
  non_na_idx <- which(!is.na(col))
  col[non_na_idx] <- sample(col[non_na_idx], replace = FALSE)
  return(col)
}))
rownames(permuted_pops) <- rownames(all_pops_p)

count <- 0
nLins <- 5
results <- list()
alpha=0.05

for (n in c(3,4,5)){
  count <- count + 1
  
  # Build null correlation matrix using fixed function and actual window count
  emp_p_null_dat <- t(replicate(10000, GenerateNullData(alpha, 0.5, 3, n, 31828)))
  emp_p_null_dat_unscaled <- t(apply(emp_p_null_dat, 1, orderStatsPValues))
  null_pMax_cor_unscaled <- cor(emp_p_null_dat_unscaled)
  
  # Filter out windows based on alpha threshold
  pops_p_screened <- permuted_pops[ apply(permuted_pops<alpha,1,function(x) sum(na.omit(x)))!=0, ]
  pops_p_n_screened <- as.matrix(pops_p_screened[rowSums(is.na(pops_p_screened)) == nLins-n,])
  
  # Initialise with NA instead of -1 to avoid FDR corruption
  # res_p <- rep(NA_real_, nrow(pops_p_n_screened))
  # res_n <- rep(NA_real_, nrow(pops_p_n_screened))
  
  if (dim(pops_p_n_screened)[1] ==0){
    next
  }
  res_p <- rep(-1, 
               nrow(pops_p_n_screened))
  res_n <- rep(-1, 
               nrow(pops_p_n_screened))
  
  for (i in seq(nrow(pops_p_n_screened)) ){
    test_result <- PicMin(na.omit(pops_p_n_screened[i,]), null_pMax_cor_unscaled, numReps = 10000)
    res_p[i] <- test_result$p
    res_n[i] <- test_result$config_est
  }
  results[[count]] = data.frame(numLin = n ,
                                p = res_p,
                                q = p.adjust(res_p, method = "fdr"),
                                n_est = res_n,
                                locus = row.names(pops_p_n_screened) )
  
}

# Step 3: Combine and FDR-adjust across all configs
permuted_results <- do.call(rbind, results)
permuted_results$'pooled_q' <- p.adjust(permuted_results$'p', method = "fdr")

saveRDS(permuted_results, paste0("permutation_results/permuted_results_", perm, ".rds"))