# This follows up HPC-ran correlation calculations
library(ggplot2)
library(dplyr)
library(tidyverse)
library(tidyr)
library(stringr)
library(data.table)

setwd("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/Tau_WZA_PicMin")
setwd("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/Tau_WZA_PicMin/20kb_results")

#### 1. LOAD AND MAP GENOMIC COORDINATES ####

# Load RagTag AGP file for chromosome mapping
gff <- read.table("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/RagTag_CSIRO2Sanger/ragtag_CSIRO-to-chrom/ragtag.scaffold.agp",
                  sep = "\t", header = FALSE, comment.char = "#",
                  fill = TRUE, quote = "", stringsAsFactors = FALSE)

colnames(gff) <- c("object", "object_beg", "object_end", "part_number",
                   "component_type", "component_id", "component_beg",
                   "component_end", "orientation")

mapping_df <- gff %>%
  filter(component_type == "W") %>%
  select(
    chrom = object,
    chrom_start = object_beg,
    chrom_end = object_end,
    contig = component_id,
    contig_start = component_beg,
    contig_end = component_end,
    strand = orientation
  ) %>%
  mutate(across(c(chrom_start, chrom_end, contig_start, contig_end), as.numeric))

setDT(mapping_df)

# Load SNP windows and extract scaffold/position
snp_windows <- read.table("snp_windows.txt")
colnames(snp_windows) <- c("snp_id", "window_id")

split_values <- do.call(rbind, strsplit(as.character(snp_windows$snp_id), ":"))
snp_windows$scaffold <- split_values[, 1]
snp_windows$position <- as.numeric(split_values[, 2])
setDT(snp_windows)

# Get first SNP per window as representative coordinate
snp_summary <- snp_windows[, .SD[1], by = window_id, .SDcols = c("scaffold", "position")]

#### 2. LOAD WZA RESULTS ####

Global_WZA          <- read.csv("wza_results/wza_output_Global.csv")
Heron_WZA           <- read.csv("wza_results/wza_output_Heron.csv")
Pelorus_WZA         <- read.csv("wza_results/wza_output_Pelorus.csv")
Moore_WZA           <- read.csv("wza_results/wza_output_Moore.csv")
Lizard_WZA          <- read.csv("wza_results/wza_output_Lizard.csv")
CentralOffshore_WZA <- read.csv("wza_results/wza_output_CentralOffshore.csv")

#### 3. LOAD PICMIN RESULTS AND DEFINE HITS ####

picmin_results <- readRDS("picMin_results.rds")
names(picmin_results)[names(picmin_results) == 'locus'] <- 'win_id'

picmin_results <- picmin_results %>%
  mutate(window_num = as.numeric(gsub("wind_", "", win_id))) %>%
  arrange(window_num)

picmin_results <- picmin_results[!duplicated(picmin_results$win_id), ]

# Define hits at FDR < 0.5
hits <- picmin_results[picmin_results$pooled_q < 0.1, ]

# how many hits for 3, 4, or 5 pops? For 10kb and 20kb
sum(hits$n_est == "2") #0 #1
sum(hits$n_est == "3") #1 #0
sum(hits$n_est == "4") #3 #1
sum(hits$n_est == "5") #7 #2

#### 4. BUILD LONG FORMAT DATAFRAME FOR MANHATTAN PLOT ####

# Calculate empirical p values
empirical_ps <- function(vector_of_values){
  1 - rank(vector_of_values) / length(vector_of_values)
}

Global_WZA$emp_p          <- empirical_ps(abs(Global_WZA$Z))
Heron_WZA$emp_p           <- empirical_ps(abs(Heron_WZA$Z))
Pelorus_WZA$emp_p         <- empirical_ps(abs(Pelorus_WZA$Z))
Moore_WZA$emp_p           <- empirical_ps(abs(Moore_WZA$Z))
Lizard_WZA$emp_p          <- empirical_ps(abs(Lizard_WZA$Z))
CentralOffshore_WZA$emp_p <- empirical_ps(abs(CentralOffshore_WZA$Z))

# Merge WZA results across populations using Z_pVal (SNP-number corrected p-value)
merged_df <- Global_WZA %>%
  full_join(Heron_WZA,           by = "gene", suffix = c("_Global", "_Heron")) %>%
  full_join(CentralOffshore_WZA, by = "gene", suffix = c("_Heron", "_CentralOffshore")) %>%
  full_join(Pelorus_WZA,         by = "gene", suffix = c("_CentralOffshore", "_Pelorus")) %>%
  full_join(Moore_WZA,           by = "gene", suffix = c("_Pelorus", "_Moore")) %>%
  full_join(Lizard_WZA,          by = "gene", suffix = c("_Moore", "_Lizard"))

names(merged_df)[names(merged_df) == 'emp_p'] <- 'emp_p_Lizard'

merged_df <- merged_df %>%
  dplyr::rename(Global          = emp_p_Global,
                Heron           = emp_p_Heron,
                CentralOffshore = emp_p_CentralOffshore,
                Pelorus         = emp_p_Pelorus,
                Moore           = emp_p_Moore,
                Lizard          = emp_p_Lizard)

# Pivot to long format
long_df <- merged_df %>%
  pivot_longer(
    cols      = c(Global, Lizard, Moore, Pelorus, CentralOffshore, Heron),
    names_to  = "population",
    values_to = "emp_p_value")

long_df[is.na(long_df)] <- 1
long_df <- transform(long_df, population = factor(population,
                                                  levels = c("Global", "Lizard", "Moore", "Pelorus", "CentralOffshore", "Heron")))

# Flag PicMin hits
long_df <- long_df %>%
  mutate(hit = if_else(gene %in% hits$win_id, "PicMin_hit", "Not_PicMin_hit"))

#### 5. ADD GENOMIC COORDINATES TO LONG FORMAT ####

long_df_coords <- snp_summary[long_df, on = .(window_id = gene)]
long_df_coords <- merge(long_df_coords, mapping_df, by.x = "scaffold", by.y = "contig", all.x = TRUE)

long_df_coords[, chrom_pos := ifelse(
  strand == "+",
  chrom_start + position - contig_start,
  chrom_end - position + contig_start
)]

long_df_coords <- long_df_coords %>%
  mutate(chrom_color = ifelse(as.numeric(factor(chrom)) %% 2 == 0, "grey10", "grey40"))

#### 6. WZA MANHATTAN PLOT ####

# Top 1% windows per population
thresholds <- long_df_coords %>%
  group_by(population) %>%
  summarise(threshold = quantile(-log10(emp_p_value), 0.99, na.rm = TRUE))

ggplot(long_df_coords, aes(x = chrom_pos, y = -log10(emp_p_value), color = chrom_color)) +
  geom_point(size = 2, alpha = 0.8) +
  
  # vertical lines for PicMin hits
  geom_vline(
    data = subset(long_df_coords, hit == "PicMin_hit"),
    aes(xintercept = chrom_pos),
    color = "maroon",
    linewidth = 1) +
  
  # horizontal line at p = 0.05 
  geom_hline(
    yintercept = -log10(0.05), # or use data = thresholds, aes(yintercept = threshold),
    color = "red",
    linetype = "dashed",
    linewidth = 0.5) +
  
  # horizontal line at  1% threshold
  geom_hline(
    data = thresholds, aes(yintercept = threshold),
    color = "black",
    linetype = "dashed",
    linewidth = 0.5) +
  
  facet_grid(rows = vars(population), cols = vars(chrom),
             space = "free_x", scales = "free_x", switch = "x") +
  scale_color_identity() +
  theme_classic() +
  theme(
    legend.position  = "none",
    axis.title.x     = element_blank(),
    axis.text.x      = element_blank(),
    axis.ticks.x     = element_blank(),
    panel.spacing.x  = unit(0.1, "cm"),
    panel.spacing.y  = unit(0.5, "cm")) +
  labs(y = "-log10(p-value)")

#### 7. SAVE OUTPUTS FOR GO ANALYSES ####

# Output file names per population
files <- list(
  Global  = "wza_output_Global.csv",
  Moore   = "wza_output_Moore.csv",
  Lizard  = "wza_output_Lizard.csv",
  Heron   = "wza_output_Heron.csv",
  Pelorus = "wza_output_Pelorus.csv",
  Central = "wza_output_CentralOffshore.csv"
)

suffix_map <- c(
  Global  = "Global",
  Moore   = "Moore",
  Lizard  = "Lizard",
  Heron   = "Heron",
  Pelorus = "Pelorus",
  Central = "CentralOffshore"
)

for (pop in names(files)) {
  
  suf <- suffix_map[[pop]]
  
  cols <- c(
    "window_id",
    paste0("SNPs_", suf),
    paste0("hits_", suf),
    paste0("Z_", suf),
    paste0("top_candidate_p_", suf),
    paste0("Z_pVal_", suf)
  )
  
  # Pull the relevant columns and collapse to one row per window/gene
  sub <- unique(long_df_coords[, ..cols])
  
  # Rename to match the original wza_output_*.csv structure
  setnames(
    sub,
    old = cols,
    new = c("gene", "SNPs", "hits", "Z", "top_candidate_p", "Z_pVal")
  )
  
  fwrite(sub, files[[pop]])
  cat("Wrote", files[[pop]], "-", nrow(sub), "rows\n")
}

#### 8. PICMIN MANHATTAN PLOT AND SUMMARY PLOTS ####

setDT(picmin_results)
picmin_coords <- snp_summary[picmin_results, on = .(window_id = win_id)]
picmin_coords <- mapping_df[picmin_coords, on = .(contig = scaffold)]

picmin_coords[, chrom_pos := fifelse(
  strand == "+",
  chrom_start + position - contig_start,
  chrom_end - position + contig_start
)]

picmin_coords <- picmin_coords[!duplicated(window_id)]

# Manhattan plot

ggplot(picmin_coords, aes(x = chrom_pos, y = -log10(pooled_q), fill = factor(n_est))) +
  geom_point(shape = 21, size = 3) +
  geom_hline(aes(yintercept = -log10(0.5)), lty = 2) +
  scale_fill_manual(values = c("#F4B6C2", "#BA55D3", "#6A0DAD", "grey")) +
  facet_grid(cols = vars(chrom), space = "free_x", scales = "free_x", switch = "x") +
  theme_bw() +
  theme(
    axis.text        = element_text(size = 10),
    axis.title       = element_text(size = 10),
    axis.title.x     = element_blank(),
    axis.text.x      = element_blank(),
    axis.ticks.x     = element_blank(),
    panel.spacing    = unit(0.1, "cm")) +
  labs(y = "-log10(q)")

# Summary plots
hits_plot <- hits %>% arrange(-pooled_q)

ggplot(hits_plot, aes(x = -log10(pooled_q), y = reorder(win_id, -log10(pooled_q)))) +
  geom_bar(stat = "identity", fill = "gray30") +
  labs(x = "-log10(q)", y = "window") +
  theme_bw()

ggplot(hits_plot, aes(x = n_est, y = reorder(win_id, -log10(pooled_q)))) +
  geom_bar(stat = "identity", fill = "gray30") +
  labs(x = "number of populations", y = "window") +
  theme_bw()

#### 9. PICMIN HITS BLAST ####
# Get the SNPs in your significant windows
sig_snps <- snp_windows[window_id %in% hits$win_id]

# Summarize to one coordinate range per window
library(dplyr)
window_coords <- sig_snps %>%
  group_by(scaffold, window_id) %>%
  summarise(start = min(position), end = max(position), .groups = "drop")

# Write a BED file (bedtools uses 0-based start)
window_coords$bed_start <- window_coords$start - 1
write.table(window_coords[, c("scaffold","bed_start","end","window_id")],
            "picmin_hits_windows.bed", sep="\t", quote=FALSE, 
            row.names=FALSE, col.names=FALSE)

# Use in terminal 
bedtools intersect -a complete.genomic.gff \
-b picmin_hits_windows.bed \
-wa | awk '$3 == "gene"' > overlapping_genes.gff

grep -oE 'ID=[^;]+' overlapping_genes.gff | sed 's/ID=//' > gene_ids.txt
cat gene_ids.txt

grep ">" complete.proteins.OMark_best_isoform_per_gene.faa | head -5
