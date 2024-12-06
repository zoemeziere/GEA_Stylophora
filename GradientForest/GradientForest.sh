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
