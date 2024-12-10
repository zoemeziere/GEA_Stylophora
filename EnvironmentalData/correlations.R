library(corrplot)
library(caret)

# Load data
X_all <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/environmental_data/GBR-level/env_data_Spis.csv", header = TRUE)

# Investigate correlation among variables
correlation <- cor(X_all[,-1], method="pearson")

corrplot(correlation, type="upper", tl.pos="td", sig.level=0.05, tl.col="black", font=2, tl.cex=0.6,
         tl.offset=0.7, cl.pos="b", mar=c(0.5,0.5,0.5,0.5), mgp=c(0,0,0), oma=c(0,0,0,0))

corr.pear <- cor(X_all[,-1], method="pearson", use="pairwise.complete.obs")

# Retain uncorrelated variables (Pearson's coef < 0.7) but keep interest variables
keep_vars <- c("salt_mean", "temp_mean", "DIC_mean", "NH4_mean", "EpiPAR_sg_mean", 
               "Secchi_mean", "PH_mean", "alk_mean", "speed_mean", "Chl_a_sum_mean")

cor_threshold <- 0.7
to_remove <- vector("logical", length = ncol(X_all[,-1]))

for(i in 1:(ncol(X_all[,-1]) - 1)){
  for(j in (i + 1):ncol(X_all[,-1])){
    if(abs(cor_matrix[i, j]) > cor_threshold){
      # If the variables are highly correlated and not in the list of variables to keep, mark one for removal
      if(!(colnames(X_all[,-1])[i] %in% keep_vars)){
        to_remove[i] <- TRUE
      } else if(!(colnames(X_all[,-1])[j] %in% keep_vars)){
        to_remove[j] <- TRUE
      }
    }
  }
}

X_uncor <- X_all[,-1][, !to_remove]
