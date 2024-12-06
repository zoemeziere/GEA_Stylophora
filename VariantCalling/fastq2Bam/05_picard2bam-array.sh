Last login: Fri Dec  6 14:50:19 on ttys000
(base) zoemeziere@d-i89-245-41 ~ % ssh uqzmezie@bunya.rcc.uq.edu.au
(uqzmezie@bunya.rcc.uq.edu.au) Password: 
(uqzmezie@bunya.rcc.uq.edu.au) Duo two-factor login for uqzmezie

Enter a passcode or select one of the following options:

Passcode: 978591
Success. Logging you in...

Welcome to Bunya! 

The UQ HPC Facility welcomes authorised clients and partners.
Access without authority is strictly prohibited.

Guides: https://github.com/UQ-RCC/hpc-docs/
For further information and support, please refer to /sw/help/Getting_Support.txt
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CURRENT STATUS

* Next maintenance Tuesday 4th February
* QOSGrpCpuLimit is the total amount of CPUs available on Bunya.
  If the job is queued due to this it means Bunya is currently full.

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Last login: Thu Dec  5 17:01:56 2024 from 10.89.245.41
[uqzmezie@bunya2 ~]$ cd /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/correlation_coefficients/
[uqzmezie@bunya2 correlation_coefficients]$ ll
total 36
drwxr-sr-x. 4 uqzmezie Q5253RW  4096 Nov 27 15:20 CentralOffshore
drwxr-sr-x. 2 uqzmezie Q5253RW 16384 Nov  6 14:07 CreateWindows
drwxr-sr-x. 3 uqzmezie Q5253RW 16384 Nov 27 17:02 Global
drwxr-sr-x. 4 uqzmezie Q5253RW  4096 Nov 27 15:21 Heron
drwxr-sr-x. 3 uqzmezie Q5253RW  4096 Oct 16 15:29 LadyMusgrave
drwxr-sr-x. 5 uqzmezie Q5253RW  4096 Nov 27 15:20 Lizard
drwxr-sr-x. 5 uqzmezie Q5253RW  4096 Nov 27 15:20 Moore
drwxr-sr-x. 4 uqzmezie Q5253RW  4096 Nov 27 15:21 Pelorus
drwxr-sr-x. 5 uqzmezie Q5253RW  4096 Nov 27 16:39 PicMin
[uqzmezie@bunya2 correlation_coefficients]$ cd CentralOffshore
[uqzmezie@bunya2 CentralOffshore]$ nano 03_WZA.sh 
[uqzmezie@bunya2 CentralOffshore]$ nano 02_KendallCorrelation.sh 
[uqzmezie@bunya2 CentralOffshore]$ cd ../../
[uqzmezie@bunya2 WGS_Stylophora_Taxon1]$ ll
total 646
drwxr-sr-x.  8 uqzmezie Q5253RW 262144 Aug  9 13:07 call_variants_GATK
drwxr-sr-x. 11 uqzmezie Q5253RW   4096 Nov 27 10:17 correlation_coefficients
drwxr-sr-x.  7 uqzmezie Q5253RW  65536 Dec  4 12:15 fastq2Bam
drwxr-sr-x.  2 uqzmezie Q5253RW  65536 Jul 24 10:12 fastq_files
drwxr-sr-x.  6 uqzmezie Q5253RW   4096 Dec  4 13:27 filtering_vcftools
drwxr-sr-x.  2 uqzmezie Q5253RW   4096 Aug 21 13:34 gradient_forest
drwxr-sr-x.  3 uqzmezie Q5253RW   4096 Nov 17 11:39 imputation
drwxr-sr-x.  2 uqzmezie Q5253RW   4096 Oct 23 15:36 LDdecay
drwxr-sr-x.  3 uqzmezie Q5253RW   4096 Oct 24 13:16 local_pca
drwxr-sr-x.  3 uqzmezie Q5253RW   4096 Aug 15 16:12 outlier_analyses
drwxr-sr-x.  5 uqzmezie Q5253RW 262144 Nov 21 06:40 PIXY
drwxr-sr-x.  2 uqzmezie Q5253RW   4096 Dec  5 14:36 RDA
drwxr-sr-x.  3 uqzmezie Q5253RW   4096 Dec  4 01:33 RDAforest
drwxr-sr-x.  2 uqzmezie Q5253RW   4096 Nov  8 15:30 reference_genome
drwxr-sr-x.  4 uqzmezie Q5253RW   4096 Oct 28 14:01 selective_sweeps
drwxr-sr-x.  6 uqzmezie Q5253RW   4096 Nov 10 15:36 snp_fst_vcftools
[uqzmezie@bunya2 WGS_Stylophora_Taxon1]$ cd RDA
[uqzmezie@bunya2 RDA]$ ll
total 8714261
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  4 10:18 col.pred_prda
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  4 10:20 col.pred_prda.rds
-rw-r--r--. 1 uqzmezie Q5253RW   91564550 Dec  1 16:21 gen.imp.rds
-rw-r--r--. 1 uqzmezie Q5253RW        348 Dec  4 17:59 importance.rds
-rw-r--r--. 1 uqzmezie Q5253RW        618 Dec  3 20:49 partialRDA_11812807.e
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  3 20:44 partialRDA_11812807.o
-rw-r--r--. 1 uqzmezie Q5253RW        618 Dec  4 06:06 partialRDA_11824172.e
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  4 05:59 partialRDA_11824172.o
-rw-r--r--. 1 uqzmezie Q5253RW       2498 Dec  4 06:52 partialRDA_11824867.e
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  4 06:52 partialRDA_11824867.o
-rw-r--r--. 1 uqzmezie Q5253RW        158 Dec  4 09:05 partialRDA_11827931.e
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  4 09:04 partialRDA_11827931.o
-rw-r--r--. 1 uqzmezie Q5253RW       5867 Dec  4 09:04 partialRDA.sh
-rw-r--r--. 1 uqzmezie Q5253RW 4193472790 Dec  4 07:37 p_rda2.rds
-rw-r--r--. 1 uqzmezie Q5253RW  120460690 Dec  4 07:41 p_rda_plot.pdf
-rw-r--r--. 1 uqzmezie Q5253RW  128530663 Dec  4 07:45 p_rda_plot_snps.pdf
-rw-r--r--. 1 uqzmezie Q5253RW  161422322 Dec  4 06:06 p_rda.rds
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  4 10:15 prda_snps_outliers.pdf
-rw-r--r--. 1 uqzmezie Q5253RW        189 Dec  3 21:38 rdaforest_11811750.e
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  3 19:08 rdaforest_11811750.o
-rw-r--r--. 1 uqzmezie Q5253RW         88 Dec  4 06:00 rdaforest_11824176.e
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  4 06:00 rdaforest_11824176.o
-rw-r--r--. 1 uqzmezie Q5253RW 4227746223 Dec  5 14:39 rda.rds
-rw-r--r--. 1 uqzmezie Q5253RW       1253 Dec  4 05:59 RDA.sh
-rw-r--r--. 1 uqzmezie Q5253RW       3611 Dec  4 10:18 Rplots.pdf
-rw-r--r--. 1 uqzmezie Q5253RW      30477 Dec  1 16:20 Spis_noreplicates_badsamples_filtered_prunned.eigenvec
-rw-r--r--. 1 uqzmezie Q5253RW      33351 Dec  3 17:26 uncor_env_data_Spis.csv
-rw-r--r--. 1 uqzmezie Q5253RW      38365 Dec  1 16:20 WGSpisTaxon1_Metadata.csv
[uqzmezie@bunya2 RDA]$ cat RDA.sh
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

SpisTaxon1_metadata <- read.csv("WGSpisTaxon1_Metadata.csv")
#evec = fread("Spis_noreplicates_badsamples_filtered_prunned.eigenvec")
X <- read.csv("uncor_env_data_Spis.csv", header = TRUE)
Y <- readRDS("gen.imp.rds")
#Xcorrected <- cbind(X, "PC1"=evec$PC1, "PC2"=evec$PC2)

# Run full model
rda <- rda(Y ~ ., data=X[,-1], scale=T)


anova_results <- anova.cca(rda, by = "term")
importance <- data.frame(Predictor = rownames(anova_results), Variance = anova_results$'Variance')

saveRDS(importance, file="importance.rds")

EOF
[uqzmezie@bunya2 RDA]$ cat partialRDA.sh
#!/bin/bash --login
#SBATCH --job-name="partialRDA"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=500G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=24:00:00         # walltime
#SBATCH --account=a_riginos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o partialRDA_%A.o         # standard output
#SBATCH -e partialRDA_%A.e             # standard error

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(vegan)
library(data.table)
library(ggplot2)

SpisTaxon1_metadata <- read.csv("WGSpisTaxon1_Metadata.csv")
evec = fread("Spis_noreplicates_badsamples_filtered_prunned.eigenvec")
X <- read.csv("uncor_env_data_Spis.csv", header = TRUE)
Y <- readRDS("gen.imp.rds")
Xcorrected <- cbind(X, "PC1"=evec$PC1, "PC2"=evec$PC2)

env_data <- Xcorrected[,2:12]
popstr <- Xcorrected[,13:14]

salt_mean <- X$salt_mean
temp_mean <- X$temp_mean
temp_daily_range <- X$temp_daily_range
speed_mean <- X$speed_mean
DIC_mean <- X$DIC_mean
NH4_mean <- X$NH4_mean
EpiPAR_sg_mean <- X$EpiPAR_sg_mean
Secchi_mean <- X$Secchi_mean
PH_mean <- X$alk_mean
alk_mean <- X$alk_mean
Chl_a_sum_mean <- X$Chl_a_sum_mean
PC1 <- evec$PC1
PC2 <- evec$PC2

#p_rda <- rda(Y ~ . + Condition(PC1 + PC2), data= env_data, scale=TRUE)

# Run model
#p_rda <- rda(Y, env_data, popstr, scale=TRUE)
p_rda <- readRDS("p_rda2.rds")

#saveRDS(p_rda, "p_rda2.rds")

#a <- screeplot(p_rda)
#round(a$y[1]/sum(a$y),3)
#round(a$y[2]/sum(a$y),3)

#prda_anova_results <- anova.cca(p_rda, by = "term")
#prda_importance <- data.frame(Predictor = rownames(prda_anova_results), Variance = prda_anova_results$'Variance')

#saveRDS(prda_importance, file="prda_importance.rds")

# Plot individuals
#bg <- c("#5C9FD1","#5CBED1","#1F7D1E","#F2C738", "#F39237", "#B05102")
#SpisTaxon1_metadata$Population <- factor(SpisTaxon1_metadata$Population, levels = c("LadyMusgrave", "Heron", "OffshoreCentral", "Pelorus", "Moore", "Lizard"))
#pop <- as.numeric(SpisTaxon1_metadata$Population)

#pdf("prda_ind.pdf")
#plot(rda, type="n", scaling=3)
#points(rda, display="species", pch=20, cex=2, col="gray32", scaling=3)           # the SNPs
#points(rda, display="sites", pch=21, cex=2, col="gray32", scaling=3, bg=bg[pop]) # the samples
#text(rda, scaling=3, display="bp", col="black", cex=1)                           # the predictors
#dev.off()

# Plot SNPs
#pdf("prda_snps.pdf")
#plot(rda, type="n", scaling=3, xlim=c(-0.5,0.5), ylim=c(-0.5,0.5))
#points(rda, display="species", pch=21, cex=1, col="gray32", scaling=3)
#text(rda, scaling=3, display="bp", col="black", cex=1)
#dev.off()

# Plots outlier SNPs

load.rda <- scores(p_rda, choices=c(1:3), display="species")  # Species scores for the first three constrained axes
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

col.pred <- rep('#f1eef6', length(rownames(p_rda$CCA$v)))
names(col.pred) <- rownames(p_rda$CCA$v)

for (i in seq_along(sel)) {
  if (sel[i] %in% names(col.pred)) {  # Ensure SNP is in col.pred
    col.pred[sel[i]] <- env[i]       # Assign corresponding color from env
  }
}

empty <- ifelse(col.pred == '#f1eef6', rgb(0, 1, 0, alpha = 0), col.pred)
empty.outline <- ifelse(empty == rgb(0, 1, 0, alpha = 0), rgb(0, 1, 0, alpha = 0), "gray32")
bg <- c('#1f78b4','#a6cee3','#6a3d9a','#e31a1c','#33a02c','#ffff33','#fb9a99','#b2df8a', "orange", "pink", "purple")

pdf("prda_snps_outliers.pdf")

plot(p_rda, type="n", scaling=3, xlim=c(-0.5,0.5), ylim=c(-0.5,0.5))
points(p_rda, display="species", pch=21, cex=1, col="gray32", bg=col.pred, scaling=3)
points(p_rda, display="species", pch=21, cex=1, col=empty.outline, bg=empty, scaling=3)
text(p_rda, scaling=3, display="bp", col="black", cex=1)



EOF
[uqzmezie@bunya2 RDA]$ ll
total 8714261
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  4 10:18 col.pred_prda
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  4 10:20 col.pred_prda.rds
-rw-r--r--. 1 uqzmezie Q5253RW   91564550 Dec  1 16:21 gen.imp.rds
-rw-r--r--. 1 uqzmezie Q5253RW        348 Dec  4 17:59 importance.rds
-rw-r--r--. 1 uqzmezie Q5253RW        618 Dec  3 20:49 partialRDA_11812807.e
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  3 20:44 partialRDA_11812807.o
-rw-r--r--. 1 uqzmezie Q5253RW        618 Dec  4 06:06 partialRDA_11824172.e
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  4 05:59 partialRDA_11824172.o
-rw-r--r--. 1 uqzmezie Q5253RW       2498 Dec  4 06:52 partialRDA_11824867.e
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  4 06:52 partialRDA_11824867.o
-rw-r--r--. 1 uqzmezie Q5253RW        158 Dec  4 09:05 partialRDA_11827931.e
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  4 09:04 partialRDA_11827931.o
-rw-r--r--. 1 uqzmezie Q5253RW       5867 Dec  4 09:04 partialRDA.sh
-rw-r--r--. 1 uqzmezie Q5253RW 4193472790 Dec  4 07:37 p_rda2.rds
-rw-r--r--. 1 uqzmezie Q5253RW  120460690 Dec  4 07:41 p_rda_plot.pdf
-rw-r--r--. 1 uqzmezie Q5253RW  128530663 Dec  4 07:45 p_rda_plot_snps.pdf
-rw-r--r--. 1 uqzmezie Q5253RW  161422322 Dec  4 06:06 p_rda.rds
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  4 10:15 prda_snps_outliers.pdf
-rw-r--r--. 1 uqzmezie Q5253RW        189 Dec  3 21:38 rdaforest_11811750.e
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  3 19:08 rdaforest_11811750.o
-rw-r--r--. 1 uqzmezie Q5253RW         88 Dec  4 06:00 rdaforest_11824176.e
-rw-r--r--. 1 uqzmezie Q5253RW          0 Dec  4 06:00 rdaforest_11824176.o
-rw-r--r--. 1 uqzmezie Q5253RW 4227746223 Dec  5 14:39 rda.rds
-rw-r--r--. 1 uqzmezie Q5253RW       1253 Dec  4 05:59 RDA.sh
-rw-r--r--. 1 uqzmezie Q5253RW       3611 Dec  4 10:18 Rplots.pdf
-rw-r--r--. 1 uqzmezie Q5253RW      30477 Dec  1 16:20 Spis_noreplicates_badsamples_filtered_prunned.eigenvec
-rw-r--r--. 1 uqzmezie Q5253RW      33351 Dec  3 17:26 uncor_env_data_Spis.csv
-rw-r--r--. 1 uqzmezie Q5253RW      38365 Dec  1 16:20 WGSpisTaxon1_Metadata.csv
[uqzmezie@bunya2 RDA]$ cd ../
[uqzmezie@bunya2 WGS_Stylophora_Taxon1]$ ll
total 646
drwxr-sr-x.  8 uqzmezie Q5253RW 262144 Aug  9 13:07 call_variants_GATK
drwxr-sr-x. 11 uqzmezie Q5253RW   4096 Nov 27 10:17 correlation_coefficients
drwxr-sr-x.  7 uqzmezie Q5253RW  65536 Dec  4 12:15 fastq2Bam
drwxr-sr-x.  2 uqzmezie Q5253RW  65536 Jul 24 10:12 fastq_files
drwxr-sr-x.  6 uqzmezie Q5253RW   4096 Dec  4 13:27 filtering_vcftools
drwxr-sr-x.  2 uqzmezie Q5253RW   4096 Aug 21 13:34 gradient_forest
drwxr-sr-x.  3 uqzmezie Q5253RW   4096 Nov 17 11:39 imputation
drwxr-sr-x.  2 uqzmezie Q5253RW   4096 Oct 23 15:36 LDdecay
drwxr-sr-x.  3 uqzmezie Q5253RW   4096 Oct 24 13:16 local_pca
drwxr-sr-x.  3 uqzmezie Q5253RW   4096 Aug 15 16:12 outlier_analyses
drwxr-sr-x.  5 uqzmezie Q5253RW 262144 Nov 21 06:40 PIXY
drwxr-sr-x.  2 uqzmezie Q5253RW   4096 Dec  5 14:36 RDA
drwxr-sr-x.  3 uqzmezie Q5253RW   4096 Dec  4 01:33 RDAforest
drwxr-sr-x.  2 uqzmezie Q5253RW   4096 Nov  8 15:30 reference_genome
drwxr-sr-x.  4 uqzmezie Q5253RW   4096 Oct 28 14:01 selective_sweeps
drwxr-sr-x.  6 uqzmezie Q5253RW   4096 Nov 10 15:36 snp_fst_vcftools
[uqzmezie@bunya2 WGS_Stylophora_Taxon1]$ cd RDAforest
[uqzmezie@bunya2 RDAforest]$ ll
total 18144611
drwxr-sr-x. 2 uqzmezie Q5253RW        4096 Dec  3 10:22 correlated_vars
-rw-r--r--. 1 uqzmezie Q5253RW        3868 Dec  4 02:06 cum_env_imp.pdf
-rw-r--r--. 1 uqzmezie Q5253RW   372406640 Nov 28 12:56 EREEFS_AIMS-CSIRO_gbr1_2.0_hydro_annual-annual-2021.nc
-rw-r--r--. 1 uqzmezie Q5253RW   148092753 Nov 26 16:07 gen.gt.t.rds
-rw-r--r--. 1 uqzmezie Q5253RW    91564550 Nov 26 18:07 gen.imp.rds
-rw-r--r--. 1 uqzmezie Q5253RW         389 Dec  4 02:06 gf_11802869.e
-rw-r--r--. 1 uqzmezie Q5253RW     2467922 Dec  4 01:33 gf_11802869.o
-rw-r--r--. 1 uqzmezie Q5253RW   353927611 Dec  4 01:33 gf.rds
-rw-r--r--. 1 uqzmezie Q5253RW        2260 Dec  3 14:25 gf.sh
-rw-r--r--. 1 uqzmezie Q5253RW        5015 Nov 26 17:35 latlon.csv
-rw-r--r--. 1 uqzmezie Q5253RW        5053 Dec  4 01:33 overall_env_imp.pdf
-rw-r--r--. 1 uqzmezie Q5253RW       19269 Nov 26 17:37 RDAforest_2.6.3.tar.gz
-rw-r--r--. 1 uqzmezie Q5253RW        3353 Dec  3 10:20 RDAforest.sh
-rw-r--r--. 1 uqzmezie Q5253RW 17611409593 Nov 25 16:06 Spis_noreplicates_badsamples_filtered_linked.vcf
-rw-r--r--. 1 uqzmezie Q5253RW       33351 Dec  1 16:20 uncor_env_data_Spis.csv
-rw-r--r--. 1 uqzmezie Q5253RW       38365 Nov 26 17:57 WGSpisTaxon1_Metadata.csv
[uqzmezie@bunya2 RDAforest]$ cat gf.sh
#!/bin/bash --login
#SBATCH --job-name="gf"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=100G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=24:00:00         # walltime
#SBATCH --account=a_riginos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o gf_%A.o         # standard output
#SBATCH -e gf_%A.e             # standard error

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(gradientForest)

Y <- readRDS("gen.imp.rds")
X <- read.csv("uncor_env_data_Spis.csv", header = TRUE)

preds <- colnames(X[,-1])
specs <- colnames(Y)

nSamples <- dim(Y)[1]
nSNPs <- dim(Y)[2]

#### Run GF ####

#maxLevel <- floor(log2(nSamples*0.368/2))

gf <- gradientForest(cbind(X[,-1],Y), predictor.vars=preds, response.vars=specs, ntree=10, transform = NULL, compact=T,nbin=101, trace=T, corr.threshold=0.50)

saveRDS(gf, "gf.rds")

#### Plot climate vars importance and turnover functions ####

# bar graphs depicting the importance of each  climate variable
pdf("overall_env_imp.pdf")
plot(gf, plot.type="Overall.Importance")
dev.off()

pdf("cum_env_imp.pdf")
plot(gf, plot.type="Cumulative.Importance")
dev.off()

# plot the "turnover functions" showing how allelic composition changes along the environmental gradients
most_important <- names(importance(gf))[1:25]

pdf("turnover_functions_env.pdf")
plot(gf, plot.type = "C", imp.vars = most_important, show.species = F, common.scale = T, cex.axis = 1, cex.lab = 1.2, line.ylab = 1, par.args = list(mgp = c(1.5, 0.5, 0), mar = c(2.5, 2, 2, 2), omi = c(0.2, 0.3, 0.2, 0.4)))
dev.off()

# plots of turnover functions for individual loci
# Each line within each panel represents allelic change at a single SNP
pdf("turnover_functions_loci.pdf")
plot(gf, plot.type = "C", imp.vars = most_important, show.overall = F, legend = T, leg.posn = "topleft", leg.nspecies = 5, cex.lab = 0.7, cex.legend = 0.4, cex.axis = 0.6, line.ylab = 0.9, par.args = list(mgp = c(1.5, 0.5, 0), mar = c(2.5, 1, 0.1, 0.5), omi = c(0, 0.3, 0, 0)))
dev.off()

EOF
[uqzmezie@bunya2 RDAforest]$ cat RDAforest.sh
#!/bin/bash --login
#SBATCH --job-name="RDAforest"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=4               # number of cores per job
#SBATCH --mem=50G                              # RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=02:00:00         # walltime
#SBATCH --account=a_riginos             # group account name
#SBATCH --partition=general             # queue name
#SBATCH -o rdaforest_%A.o         # standard output
#SBATCH -e rdaforest_%A.e             # standard error

module load r/4.2.1-foss-2022a

Rscript - <<EOF

library(RDAforest)
library(rnaturalearth)
library(rnaturalearthdata)
library(terra)
library(viridis)
library(adegenet)
library(vcfR)

#Read in and prepare the genetic data
#gen <- read.vcfR("Spis_noreplicates_badsamples_filtered_linked.vcf")

#str(gen)

#gen.gt <- extract.gt(gen)
#gen.gt.t <- t(gen.gt)
#sum(is.na(gen.gt.t)) #59466012

#gen.gt.t[gen.gt.t %in% c("0|0", "0/0")] <- 0
#gen.gt.t[gen.gt.t %in% c("0|1", "0/1")] <- 1
#gen.gt.t[gen.gt.t %in% c("1|1", "1/1")] <- 2

#saveRDS(gen.gt.t, "gen.gt.t.rds")

#gen.imp <- apply(gen.gt.t, 2, function(x) replace(x, is.na(x), as.numeric(names(which.max(table(x))))))
#sum(is.na(gen.imp)) #0
#class(gen.imp) <- "numeric"

#saveRDS(gen.imp, "gen.imp.rds")
gen.imp <- readRDS("gen.imp.rds")

# Read in and screen the environmental predictors

#env <- read.csv("env_data_Spis.csv")
env <- read.csv("uncor_env_data_Spis.csv")
str(env)
identical(rownames(gen.imp), env[,1]) #TRUE

# Cleaning predictors 

pc=hclust(as.dist(1-cor(env[,-1])))
plot(pc)
abline(h=0.1, col="red")

# Genetic distances

lonlat <- read.csv(“lonlat.csv”)

GCD=gcd.dist(latlon) # convert lat, lon to great circle distances
latlon.gcd=GCD[[1]]
distGCD=GCD[[2]]

# pca

metadata <- read.csv(“metadata.csv”)

cordist=1-cor(t(gen.imp)) # genetic distance
ord=capscale(cordist~1) # ordination
so=data.frame(scores(ord,scaling=1,display="sites"))
ggplot(so,aes(MDS1,MDS2,color=metadata$EcoReefID))+geom_point()+coord_equal()+theme_bw()

#remove IBD

ord1=capscale(cordist~1+Condition(as.matrix(latlon.gcd)))
so1=data.frame(scores(ord1,scaling=1,display="sites"))
ggplot(so1,aes(MDS1,MDS2,color=metadata$EcoReefID))+geom_point()+coord_equal()+theme_bw()

#saveRDS(ord1, "ord1.rds")

# Exploratory RDA-forest analysis

gf=makeGF(ord1,env[,-1],pcs2keep=c(1:40))
gf$result

#saveRDS(gf, “gf.rds”)

eigen.var=(ord1$CA$eig/sum(ord1$CA$eig))[names(gf$result)] # rescaling to proportion of total variance
sum(eigen.var*gf$result) # total variance explained by model = 0.08906774 so about 9%

tokeep=19 # number of PCs to keep
imps=data.frame(importance_RDAforest(gf,ord1)) # computing properly scaled importances
names(imps)="R2"
imps$var=row.names(imps)
imps$var=factor(imps$var,levels=imps$var[order(imps$R2)]) # reordering predictors by their importances

ggplot(imps,aes(var,R2))+geom_bar(stat="identity")+coord_flip()+theme_bw

# Turnover curves

plot_gf_turnovers(gf,imps$var[1:6])

# Variable selection

mm=mtrySelJack(Y=cordist,X=env[,-1],covariates=latlon.gcd,nreps=50, top.pcs=tokeep)
mm$goodvars
#saveRDS(mm, “mm.rds”)

ggplot(mm$delta,aes(var,values))+
  geom_boxplot(outlier.shape = NA)+
  coord_flip()+
  geom_hline(yintercept=0,col="red")
[uqzmezie@bunya2 RDAforest]$ ll
total 18144611
drwxr-sr-x. 2 uqzmezie Q5253RW        4096 Dec  3 10:22 correlated_vars
-rw-r--r--. 1 uqzmezie Q5253RW        3868 Dec  4 02:06 cum_env_imp.pdf
-rw-r--r--. 1 uqzmezie Q5253RW   372406640 Nov 28 12:56 EREEFS_AIMS-CSIRO_gbr1_2.0_hydro_annual-annual-2021.nc
-rw-r--r--. 1 uqzmezie Q5253RW   148092753 Nov 26 16:07 gen.gt.t.rds
-rw-r--r--. 1 uqzmezie Q5253RW    91564550 Nov 26 18:07 gen.imp.rds
-rw-r--r--. 1 uqzmezie Q5253RW         389 Dec  4 02:06 gf_11802869.e
-rw-r--r--. 1 uqzmezie Q5253RW     2467922 Dec  4 01:33 gf_11802869.o
-rw-r--r--. 1 uqzmezie Q5253RW   353927611 Dec  4 01:33 gf.rds
-rw-r--r--. 1 uqzmezie Q5253RW        2260 Dec  3 14:25 gf.sh
-rw-r--r--. 1 uqzmezie Q5253RW        5015 Nov 26 17:35 latlon.csv
-rw-r--r--. 1 uqzmezie Q5253RW        5053 Dec  4 01:33 overall_env_imp.pdf
-rw-r--r--. 1 uqzmezie Q5253RW       19269 Nov 26 17:37 RDAforest_2.6.3.tar.gz
-rw-r--r--. 1 uqzmezie Q5253RW        3353 Dec  3 10:20 RDAforest.sh
-rw-r--r--. 1 uqzmezie Q5253RW 17611409593 Nov 25 16:06 Spis_noreplicates_badsamples_filtered_linked.vcf
-rw-r--r--. 1 uqzmezie Q5253RW       33351 Dec  1 16:20 uncor_env_data_Spis.csv
-rw-r--r--. 1 uqzmezie Q5253RW       38365 Nov 26 17:57 WGSpisTaxon1_Metadata.csv
[uqzmezie@bunya2 RDAforest]$ cd ..
[uqzmezie@bunya2 WGS_Stylophora_Taxon1]$ ll
total 646
drwxr-sr-x.  8 uqzmezie Q5253RW 262144 Aug  9 13:07 call_variants_GATK
drwxr-sr-x. 11 uqzmezie Q5253RW   4096 Nov 27 10:17 correlation_coefficients
drwxr-sr-x.  7 uqzmezie Q5253RW  65536 Dec  4 12:15 fastq2Bam
drwxr-sr-x.  2 uqzmezie Q5253RW  65536 Jul 24 10:12 fastq_files
drwxr-sr-x.  6 uqzmezie Q5253RW   4096 Dec  4 13:27 filtering_vcftools
drwxr-sr-x.  2 uqzmezie Q5253RW   4096 Aug 21 13:34 gradient_forest
drwxr-sr-x.  3 uqzmezie Q5253RW   4096 Nov 17 11:39 imputation
drwxr-sr-x.  2 uqzmezie Q5253RW   4096 Oct 23 15:36 LDdecay
drwxr-sr-x.  3 uqzmezie Q5253RW   4096 Oct 24 13:16 local_pca
drwxr-sr-x.  3 uqzmezie Q5253RW   4096 Aug 15 16:12 outlier_analyses
drwxr-sr-x.  5 uqzmezie Q5253RW 262144 Nov 21 06:40 PIXY
drwxr-sr-x.  2 uqzmezie Q5253RW   4096 Dec  5 14:36 RDA
drwxr-sr-x.  3 uqzmezie Q5253RW   4096 Dec  4 01:33 RDAforest
drwxr-sr-x.  2 uqzmezie Q5253RW   4096 Nov  8 15:30 reference_genome
drwxr-sr-x.  4 uqzmezie Q5253RW   4096 Oct 28 14:01 selective_sweeps
drwxr-sr-x.  6 uqzmezie Q5253RW   4096 Nov 10 15:36 snp_fst_vcftools
[uqzmezie@bunya2 WGS_Stylophora_Taxon1]$ cd fastq2Bam
[uqzmezie@bunya2 fastq2Bam]$ ll
total 294
-rw-r--r--. 1 uqzmezie Q5253RW   699 Jul 24 10:14 01_fastqc-array.sh
-rw-r--r--. 1 uqzmezie Q5253RW   682 Jul 23 14:49 02_multiqc.sh
-rw-r--r--. 1 uqzmezie Q5253RW  1616 Jul 24 11:35 03_trimmomatic-array.sh
-rw-r--r--. 1 uqzmezie Q5253RW  1844 Jul 25 12:22 04_bwa2samtools-array.sh
-rw-r--r--. 1 uqzmezie Q5253RW  2028 Jul 25 12:24 05_picard2bam-array.sh
-rw-r--r--. 1 uqzmezie Q5253RW  1781 Sep  2 16:45 06_extract-bam-unmapped-array.sh
-rw-r--r--. 1 uqzmezie Q5253RW  1374 Jul 29 21:54 07_samtools-bamStats.sh
-rw-r--r--. 1 uqzmezie Q5253RW   262 Jul 23 14:49 adapters.txt
-rw-r--r--. 1 uqzmezie Q5253RW  6612 Jul 29 07:58 bamList
drwxr-sr-x. 2 uqzmezie Q5253RW 65536 Jul 29 22:02 bam_stats
-rw-r--r--. 1 uqzmezie Q5253RW   826 Jul 25 12:26 checkReadGroups.sh
-rw-r--r--. 1 uqzmezie Q5253RW   943 Jul 25 12:25 count-reads.sh
drwxr-sr-x. 2 uqzmezie Q5253RW 65536 Jul 25 12:18 fastq_clean
-rw-r--r--. 1 uqzmezie Q5253RW  8271 Jul 25 12:18 fastqClean
drwxr-sr-x. 2 uqzmezie Q5253RW  4096 Jul 23 14:50 fastqc_output
-rw-r--r--. 1 uqzmezie Q5253RW  5664 Jul 24 10:12 fastqList
-rwxr-xr-x. 1 uqzmezie Q5253RW  6849 Jul 29 21:12 markedRG_bamList
drwxr-sr-x. 2 uqzmezie Q5253RW 65536 Dec  4 12:16 markedRG_bamUSE
-rw-r--r--. 1 uqzmezie Q5253RW  1035 Jul 23 14:50 samtools-index.sh
drwxr-sr-x. 2 uqzmezie Q5253RW 32768 Sep  3 07:18 unmapped_bamUSE
[uqzmezie@bunya2 fastq2Bam]$ cat 01_fastqc-array.sh
#!/bin/bash --login
#SBATCH --job-name="fastqc"     # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1		# use 1 for single and multi core jobs
#SBATCH --cpus-per-task=1		# number of cores per job
#SBATCH --mem=100G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=20:00:00			# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH -o fqc_%A_%a.o          # standard output
#SBATCH -e fqc_%A_%a.e	        # standard erro

module load fastqc/0.11.9-java-11


fastqc --extract /scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/fastq_files/* -f fastq -o fastqc_output
[uqzmezie@bunya2 fastq2Bam]$ nano 02_multiqc.sh
[uqzmezie@bunya2 fastq2Bam]$ cat 03_trimmomatic-array.sh 
#!/bin/bash --login
#SBATCH --job-name="trim"       # job name
#SBATCH --nodes=1               # use 1 node
#SBATCH --ntasks-per-node=1     # use 1 for single and multi core jobs
#SBATCH --cpus-per-task=1		# number of cores per job
#SBATCH --mem=200G				# RAM per job given in megabytes (M), gigabytes (G), or terabytes (T)
#SBATCH --time=20:00:00			# walltime
#SBATCH --account=a_riginos		# group account name
#SBATCH --partition=general		# queue name
#SBATCH --array=1-237        	# job array
#SBATCH -e trim_%A_%a.e      	# standard error
#SBATCH -o trim_%A_%a.o

# text fille including all fastq file names
LIST=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/fastq2Bam/fastqList
INDIR=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/fastq_files
OUTDIR=/scratch/project/phd_coral_genomics/WGS_Stylophora_Taxon1/fastq2Bam/fastq_clean

# file name variable is associated ARRAY index
FILENAME=`cat ${LIST} | tail -n +${SLURM_ARRAY_TASK_ID} | head -1`
BASE=`basename ${FILENAME} _1.fq.gz`

module load anaconda3/2022.05
source activate trimmomatic

trimmomatic PE -phred33 ${INDIR}/${BASE}_1.fq.gz ${INDIR}/${BASE}_2.fq.gz \
${OUTDIR}/${BASE}_R1_paired.fastq.gz ${OUTDIR}/${BASE}_R1_unpaired.fastq.gz \
${OUTDIR}/${BASE}_R2_paired.fastq.gz ${OUTDIR}/${BASE}_R2_unpaired.fastq.gz \
ILLUMINACLIP:adapters.txt:2:30:10:4:true SLIDINGWINDOW:4:20 MINLEN:50

# Notes:
# trimmomatic-0.39
# Keep bases with phred-score quality > 20 in sliding window of 4 bp (average)
# Remove adapter sequences in user specified file
# Remove reads with length < 50bp following trimming
# **keepBothReads** option = True
[uqzmezie@bunya2 fastq2Bam]$ nano 04_bwa2samtools-array.sh 
[uqzmezie@bunya2 fastq2Bam]$ nano 05_picard2bam-array.sh 

  GNU nano 2.9.8                                05_picard2bam-array.sh                                          

        RGID=$(echo $BASE | cut -d"_" -f1) \
        RGLB=$(echo $BASE | cut -d"-" -f1,2,3) \
        RGPL=Illumina \
        RGPU=$(echo $BASE | cut -d"_" -f2) \
        RGSM=$(echo $BASE | cut -d"_" -f1) \

# mark and remove PCR duplicates
picard MarkDuplicates \
        VALIDATION_STRINGENCY=LENIENT \
        TMP_DIR=${TMPDIR}/MarkDUP \
        INPUT=${OUTDIR}/${BASE}_RG.UNDEDUP.bam \
        OUTPUT=${OUTDIR}/${BASE}_markedRG.bam \
        REMOVE_DUPLICATES=true \
        METRICS_FILE=${OUTDIR}/${BASE}-markDup_metrics.txt

# remove temp files
rm *_RG.UNDEDUP.bam
