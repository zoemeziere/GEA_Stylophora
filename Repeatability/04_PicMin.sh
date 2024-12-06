#!/bin/bash --login
#SBATCH --job-name="picmin"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=100G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=48:00:00         # walltime
#SBATCH --account=a_riginos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o picmin_%A.o         # standard output
#SBATCH -e picmin_%A.e             # standard error

module load r/4.2.1-foss-2022a

Rscript - <<EOF

# PicMin functions

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


library(PicMin)
library(tidyverse)
library(poolr)

Moore <- readRDS("Moore_WZA_df.rds")
Lizard <- readRDS("Lizard_WZA_df.rds")
Pelorus <- readRDS("Pelorus_WZA_df.rds")
CentralOffshore <- readRDS("CentralOffshore_WZA_df.rds")
Heron <- readRDS("Heron_WZA_df.rds")

# Calculate p values from WZA score

Moore$'emp_p' <- PicMin:::EmpiricalPs(Moore$'WZA', large_i_small_p=TRUE)
Lizard$'emp_p' <- PicMin:::EmpiricalPs(Lizard$'WZA', large_i_small_p=TRUE)
Pelorus$'emp_p' <- PicMin:::EmpiricalPs(Pelorus$'WZA', large_i_small_p=TRUE)
CentralOffshore$'emp_p' <- PicMin:::EmpiricalPs(CentralOffshore$'WZA', large_i_small_p=TRUE)
Heron$'emp_p' <- PicMin:::EmpiricalPs(Heron$'WZA', large_i_small_p=TRUE)

# Minimise dataframes

min_pop <- function( population_df , population_name){
  tmp <- data.frame(emp_p = population_df$'emp_p',
                     win_id = population_df$'win_id')
  names(tmp) <- c(population_name, "win_id")
  return(tmp)
}

Moore_m <- min_pop(Moore, "Moore")
Lizard_m <- min_pop(Lizard, "Lizard")
Pelorus_m <- min_pop(Pelorus, "Pelorus")
CentralOffshore_m <- min_pop(CentralOffshore, "CentralOffshore")
Heron_m <- min_pop(Heron, "Heron")

# Combine data frames for each population

df_list <- list(Moore_m, Lizard_m, Pelorus_m, CentralOffshore_m, Heron_m)

all_pops <- df_list %>% reduce(full_join, by='win_id')

all_pops_p <- all_pops[ , !(names(all_pops) %in% c("win_id"))] # remove the column named win_id
rownames(all_pops_p) <- all_pops$'win_id'

# Caculate null correlation matrix and apply PicMin
count=0
nLins=5
results = list()

for (n in c(2,3,4,5)){
  count = count + 1
  # Run 10,000 replicate simulations of this situation and build the correlation matrix
  emp_p_null_dat <- t(replicate(40000, GenerateNullData(0.05, 0.5, 3, n, 1000)))
  # Calculate the order statistics p-values for each simulation
  emp_p_null_dat_unscaled <- t(apply(emp_p_null_dat ,1, orderStatsPValues))
  # Use those p-values to construct the correlation matrix
  null_pMax_cor_unscaled <- cor(emp_p_null_dat_unscaled)

  # Screen out gene with no evidence for adaptation
  pops_p_screened <- all_pops_p[apply(all_pops_p <0.05,1,function(x) sum(na.omit(x)))!=0, ]
  pops_p_n_screened <-  as.matrix(pops_p_screened[rowSums(is.na(pops_p_screened)) == nLins-n,])

  res_p <- rep(-1, nrow(pops_p_n_screened))
  res_n <- rep(-1, nrow(pops_p_n_screened))
}

for (i in seq(nrow(pops_p_n_screened)) ){
  test_result <- PicMin(na.omit(pops_p_n_screened[i,]), null_pMax_cor_unscaled, numReps = 10000)
  res_p[i] <- test_result$'p'
  res_n[i] <- test_result$'config_est'
}

for (n in c(2,3,4,5)){
  results[[count]] = data.frame(numLin = n ,
                                p = res_p,
                                q = p.adjust(res_p, method = "fdr"),
                                n_est = res_n,
                                window = row.names(pops_p_n_screened))
}

picMin_results <- do.call(rbind, results)

picMin_results$'q' <- p.adjust(picMin_results$'p', method = "fdr")

saveRDS(picMin_results, "picMin_results.rds")
