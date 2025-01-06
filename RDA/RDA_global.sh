#!/bin/bash --login
#SBATCH --job-name="RDA"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=500G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=24:00:00         # walltime
#SBATCH --account=a_riginos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o rdaforest_%A.o         # standard output
#SBATCH -e rdaforest_%A.e             # standard error

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(vegan)
library(data.table)
library(ggplot2)

# metadata, environmental and genomic data
SpisTaxon1_metadata <- read.csv("WGSpisTaxon1_Metadata.csv")
X <- read.csv("env_data_Spis_uncor.csv", header = TRUE)
Y <- readRDS("SpisTaxon1_linked_imputed.rds")

X <- X[match(rownames(Y), X$'Samples.renames'), ]
X <- X[,-2] # remove sample names

##### Full global RDA model  ####

# Set up model
rda <- rda(Y ~ ., data=X[,-1], scale=T)
saveRDS(rda, "global_rda.rds")

# test env predictor significance
rda_anova_results <- anova.cca(rda, by = "term")
saveRDS(rda_anova_results, file="rda_anova.rds")

rda_importance <- data.frame(Predictor = rownames(rda_anova_results), Variance = rda_anova_results$'Variance')
saveRDS(rda_importance, file="rda_importance.rds")

##### Full global RDA model conditionning for sampling site  ####

X$EcoLocationID_short  <- as.numeric(as.factor(X$EcoLocationID_short))
env_vars <- setdiff(names(X), "EcoLocationID_short")  # All predictors except the conditional variable
formula <- as.formula(paste("Y ~", paste(env_vars, collapse = " + "), "+ Condition(EcoLocationID_short)"))

rda_blocks <- rda(formula, data = X, scale = TRUE)
saveRDS(rda_blocks, "global_rda_blocks.rds")

#### RDA plot with individuals and env vectors ####

bg <- c("#5C9FD1","#5CBED1","#1F7D1E","#F2C738", "#F39237", "#B05102")
SpisTaxon1_metadata$Population <- factor(SpisTaxon1_metadata$Population, levels = c("LadyMusgrave", "Heron", "OffshoreCentral", "Pelorus", "Moore", "Lizard"))
pop <- as.numeric(SpisTaxon1_metadata$Population)

pdf("rda_ind.pdf")
plot(rda, type="n", scaling=3)
points(rda, display="species", pch=20, cex=2, col="gray32", scaling=3)           # the SNPs
points(rda, display="sites", pch=21, cex=2, col="gray32", scaling=3, bg=bg[pop]) # the samples
text(rda, scaling=3, display="bp", col="black", cex=1)                           # the predictors
dev.off()

#### RDA plot with SNPs and env vectors ####

pdf("rda_snps.pdf")
plot(rda, type="n", scaling=3, xlim=c(-0.5,0.5), ylim=c(-0.5,0.5))
points(rda, display="species", pch=21, cex=1, col="gray32", scaling=3)
text(rda, scaling=3, display="bp", col="black", cex=1)
dev.off()

#### Find RDA outliers and plot them ####

load.rda <- scores(rda, choices=c(1:3), display="species")  # Species scores for the first three constrained axes
outliers <- function(x,z){
  lims <- mean(x) + c(-1, 1) * z * sd(x)     # find loadings +/-z sd from mean loading     
  x[x < lims[1] | x > lims[2]]               # locus names in these tails
}

cand1 <- outliers(load.rda[,1],3.5) 
cand2 <- outliers(load.rda[,2],3.5)
cand3 <- outliers(load.rda[,3],3.5)
ncand <- length(cand1) + length(cand2) + length(cand3) # 75930 cand SNPs for 3sd; 36363 and SNPs for 3.5sd

cand1 <- cbind.data.frame(rep(1,times=length(cand1)), names(cand1), unname(cand1))
cand2 <- cbind.data.frame(rep(2,times=length(cand2)), names(cand2), unname(cand2))
cand3 <- cbind.data.frame(rep(3,times=length(cand3)), names(cand3), unname(cand3))
colnames(cand1) <- colnames(cand2) <- colnames(cand3) <- c("axis","snp","loading")
cand <- rbind(cand1, cand2, cand3)
cand$snp <- as.character(cand$snp)
foo <- matrix(nrow=(ncand), ncol=11)  # 11 columns for 11 predictors
colnames(foo) <- c("salt_mean","temp_mean","temp_daily_range","speed_mean","DIC_mean","NH4_mean","EpiPAR_sg_mean","Secchi_mean", "PH_mean", "alk_mean", "Chl_a_sum_mean")

for (i in 1:length(cand$snp)) {
  nam <- cand[i,2]
  snp.gen <- Y[,nam]
  foo[i,] <- apply(X[,-1],2,function(x) cor(x,snp.gen))
}
cand <- cbind.data.frame(cand,foo) 

foo <- cbind(cand$axis, duplicated(cand$snp))
cand <- cand[!duplicated(cand$snp),]

for (i in 1:length(cand$snp)) {
  bar <- cand[i,]
  cand[i,15] <- names(which.max(abs(bar[4:14]))) # gives the variable
  cand[i,16] <- max(abs(bar[4:14]))              # gives the correlation
}

colnames(cand)[15] <- "predictor"
colnames(cand)[16] <- "correlation"

sel <- cand$snp
env <- cand$predictor
env[env=="salt_mean"] <- '#1f78b4'
env[env=="temp_mean"] <- '#a6cee3'
env[env=="temp_daily_range"] <- '#6a3d9a'
env[env=="speed_mean"] <- '#e31a1c'
env[env=="DIC_mean"] <- '#33a02c'
env[env=="NH4_mean"] <- '#ffff33'
env[env=="EpiPAR_sg_mean"] <- '#fb9a99'
env[env=="Secchi_mean"] <- '#b2df8a'
env[env=="PH_mean"] <- 'orange'
env[env=="alk_mean"] <- 'pink'
env[env=="Chl_a_sum_mean"] <- 'purple'

# color by predictor:

col.pred <- rep('#f1eef6', length(rownames(rda$CCA$v)))
names(col.pred) <- rownames(rda$CCA$v)

for (i in seq_along(sel)) {
  if (sel[i] %in% names(col.pred)) {  # Ensure SNP is in col.pred
    col.pred[sel[i]] <- env[i]       # Assign corresponding color from env
  }
}

empty <- ifelse(col.pred == '#f1eef6', rgb(0, 1, 0, alpha = 0), col.pred)
empty.outline <- ifelse(empty == rgb(0, 1, 0, alpha = 0), rgb(0, 1, 0, alpha = 0), "gray32")
bg <- c('#1f78b4','#a6cee3','#6a3d9a','#e31a1c','#33a02c','#ffff33','#fb9a99','#b2df8a', "orange", "pink", "purple")

pdf("rda_snps_outliers.pdf")

plot(rda, type="n", scaling=3, xlim=c(-0.5,0.5), ylim=c(-0.5,0.5))
points(rda, display="species", pch=21, cex=1, col="gray32", bg=col.pred, scaling=3)
points(rda, display="species", pch=21, cex=1, col=empty.outline, bg=empty, scaling=3)
text(rda, scaling=3, display="bp", col="black", cex=1)

EOF
