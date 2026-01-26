library(vegan)
library(readr)

# ----------------------------
# Get population argument
# ----------------------------
args <- commandArgs(trailingOnly = TRUE)
if(length(args) < 1){
  stop("Please provide population name as first argument")
}
pop <- args[1]
cat("Processing population:", pop, "\n")

# ----------------------------
# Load RDA model
# ----------------------------
rda_model <- readRDS(paste0("rda_models/rda_", pop, ".rds"))

# ----------------------------
# Overall significance of the model
# ----------------------------
set.seed(123)  # for reproducibility
anova_overall <- anova.cca(rda_model, permutations = 999)

# Save results
write_csv(as.data.frame(anova_overall), paste0("rda_models/rda_", pop, "_anova_overall.csv"))

cat("Finished processing population:", pop, "\n")

