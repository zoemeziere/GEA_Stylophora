# Based on example https://fromthebottomoftheheap.net/2014/11/03/randomized-complete-block-designs-and-vegan/
# Using this to understanding how blocks and nested structures work

library(vegan)
library(gdata)
library(readxl)



## Download the data zip
furl <- "http://regent.prf.jcu.cz/maed2/chap15.zip"
td <- tempdir()
tf <- tempfile(tmpdir = td, fileext = ".zip")
download.file(furl, tf)

## list the files in the zip, we want the xls version (file 3)
fname <- unzip(tf, list = TRUE)$Name[3]
unzip(tf, files = fname, exdir = td, overwrite = TRUE) # unzip
datpath <- file.path(td, fname)                        # path to xls

## read the xls file, sheet 2 contains species data, sheet 3 the env
#spp <- read_excel(datpath, sheet = 2, skip = 1, row.names = 1)
spp <- read_excel(datpath, sheet = 2, col_names = TRUE, skip = 1)
env <- read_excel(datpath, sheet = 3, col_names = TRUE, skip = 1)

# turn spp into data frame and make first column into row names
spp <- as.data.frame(spp)
rownames(spp) <- spp$Species
spp <- spp[,-1]

# same for env
env <- as.data.frame(env)
rownames(env) <- env$Species
env <- env[,-1] 

# The block variable is currently coded as an integer and needs converting to a factor if we are to use it correctly in the analysis
env <- transform(env, block = factor(block))
# look at this object to understand the experimental design - 4 treatments per block

# not sure why this is needed, but it is in the example
decorana(spp)

# Now to test the effect of treatments 
mod1 <- rda(spp ~ treatment + Condition(block), data = env)
mod1
eigenvals(mod1) / mod1$tot.chi

# Design based permutations - samples are permuted within blocks 
h <- how(blocks = env$block, nperm = 999)
set.seed(42)
p1 <- anova(mod1, permutations = h, parallel = 3)
p1 #"The overall permutation test indicates no significant effect of treatment on the abundance of seedlings. We can test individual axes by adding by = "axis" to the anova() call"

# test individual axes 
set.seed(24)
p1axis <- anova(mod1, permutations = h, parallel = 3, by = "axis")
p1axis

# (tutorial shows how to plot)

# Model based permutation = permutation of residuals after covariables have been accounted for
setBlocks(h) <- NULL                    # remove blocking
getBlocks(h)                            # confirm

set.seed(51)
p2 <- anova(mod1, permutations = h, parallel = 3)
p2

# look at axes
set.seed(83)
p2axis <- anova(mod1, permutations = h, parallel = 3, by = "axis")
p2axis



# More details on how to set up hierarchical designs
#https://cran.r-project.org/web/packages/permute/vignettes/permutations.html
