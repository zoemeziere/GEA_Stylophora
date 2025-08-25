module load r/4.4.2

library(ggplot2)
library(terra)

historical <- readRDS("path/to/historical.rds")
future_SSP_2050 <- readRDS("path/to/future.rds")
future_SSP_2100 <- readRDS("path/to/future.rds")
future_SSP_2050 <- readRDS("path/to/future.rds")
future_SSP_2100 <- readRDS("path/to/future.rds")
future_SSP_2050 <- readRDS("path/to/future.rds")
future_SSP_2100 <- readRDS("path/to/future.rds")

future_list <- list(future1, future2, future3, future4, future5, future6)

par(mfrow = c(2, 3), mar = c(4, 4, 2, 1))

for (i in seq_along(future_list)) {
  future <- future_list[[i]]
  
  # Resample future to match historical if needed
  if (!compareGeom(historical, future)) {
    future <- resample(future, historical)
  }

  # Get values
  hist_vals <- values(historical)
  fut_vals <- values(future)
  
  # Remove NA values
  valid <- !is.na(hist_vals) & !is.na(fut_vals)

  # Optional: sample to improve speed
  if (sum(valid) > 10000) {
    set.seed(1)
    samp <- sample(which(valid), 10000)
  } else {
    samp <- which(valid)
  }

  # Scatter plot
  plot(hist_vals[samp], fut_vals[samp],
       xlab = "Historical Temp",
       ylab = "Future Temp",
       main = paste("Future", i),
       pch = 20, cex = 0.5, col = rgb(0, 0, 1, 0.3))
}
