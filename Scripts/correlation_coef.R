# This follows up HPC-ran correlation calculations
library(ggVennDiagram)

setwd("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/correlation_coef")

correlation_results <- read.csv("cor_results_LadyM.csv")

colnames(correlation_results) <- c("snp", "Kendall", "p_val")
correlation_results <- correlation_results[order(correlation_results$snp),]

correlation_results$order <- seq.int(nrow(correlation_results))
correlation_results$empirical_p <- rank(correlation_results$p_val)/length(correlation_results$p_val)
correlation_results$z_score <- qnorm(correlation_results$empirical_p, lower.tail = F)

# Plots
ggplot(data = correlation_results, aes(x= order, y= Kendall))+
  geom_point()+
  theme_bw()

ggplot(data = correlation_results, aes(x= order, y= -log10(p_val)))+
  geom_point()+
  geom_hline(yintercept= -log10(0.05), col = "red")+
  theme_bw()

ggplot(data = correlation_results, aes(x= order, y= -log10(empirical_p)))+
  geom_point()+
  geom_hline(aes(yintercept= quantile(-log10(empirical_p), 0.99)), col= "red")+
  theme_bw()

ggplot(data = correlation_results, aes(x= order, y= z_score))+
  geom_point()+
  theme_bw()

# Extract significant SNPs, based on p-values
top_candidates_Lizard <- correlation_results[which(correlation_results$p_val<0.05),1]
top_candidates_OffshoreCentral <- correlation_results[which(correlation_results$p_val<0.05),1]
top_candidates_Moore <- correlation_results[which(correlation_results$p_val<0.05),1]
top_candidates_Heron <- correlation_results[which(correlation_results$p_val<0.05),1]
top_candidates_Pelorus <- correlation_results[which(correlation_results$p_val<0.05),1]
top_candidates_LadyM <- correlation_results[which(correlation_results$p_val<0.05),1]

# intersect / venn diagram
x= list('Lizard'=top_candidates_Lizard,
        'Heron'=top_candidates_Heron,
        'Offshore Central'=top_candidates_OffshoreCentral,
        'Moore'=top_candidates_Moore,
        'LadyM'=top_candidates_LadyM,
        'Pelorus'=top_candidates_Pelorus)

Reduce(intersect, x)
ggVennDiagram(x)
