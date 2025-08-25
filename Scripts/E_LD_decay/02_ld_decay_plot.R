setwd("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/LDdecay")

library(data.table)
library(ggplot2)

data <- fread("Spis_noreplicates_badsamples_filtered_linked.ld")

# Calculate absolute distance between SNP pairs
data$distance <- abs(data$BP_A - data$BP_B)
data[, distance := abs(BP_A - BP_B)]

# Filter for pairs less than 100kb apart
data_100kb <- data[distance < 100000]

# Remove rows with missing values in R2 or distance
data_100kb <- data_100kb[!is.na(R2) & !is.na(distance)]

# Bin distances into 100bp bins
bin_size <- 100
data_100kb[, bin := floor(distance / bin_size) * bin_size]

# Calculate mean R2 per bin
binned <- data_100kb[, .(mean_R2 = mean(R2), count = .N), by = bin]

# Fit loess on binned data
loess_fit <- loess(mean_R2 ~ bin, data = binned, span = 0.3)
binned[, loess_pred := predict(loess_fit)]

# Plot

binned[, mean_R2_scaled := mean_R2 * 10]

ggplot(binned, aes(x = bin, y = mean_R2_scaled)) +
  geom_point(color = "black", size = 1.5) +
  geom_smooth(method = "loess", span = 0.3, color = "red", size = 1) +
  labs(x = "Distance (bp)", y = expression(Linkage~Disequilibrium~(r^2))) +
  xlim(0, 50000) +
  theme_bw()

