# This follows up HPC-ran correlation calculations
library(ggplot2)
library(dplyr)
library(tidyverse)
library(tidyr)
library(stringr)
library(data.table)

setwd("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/Tau_WZA_PicMin")

#### WZA ####
Global_WZA <- read.csv("wza_output_Global.csv")
Heron_WZA <- read.csv("wza_output_Heron.csv")
Pelorus_WZA <- read.csv("wza_output_Pelorus.csv")
Moore_WZA <- read.csv("wza_output_Moore.csv")
Lizard_WZA <- read.csv("wza_output_Lizard.csv")
CentralOffshore_WZA <- read.csv("wza_output_CentralOffshore.csv")

merged_df <- Global_WZA %>%
  full_join(Heron_WZA, by = "gene", suffix = c("_Global", "_Heron")) %>%
  full_join(CentralOffshore_WZA, by = "gene", suffix = c("_Heron", "_CentralOffshore")) %>%
  full_join(Pelorus_WZA, by = "gene", suffix = c("_CentralOffshore", "_Pelorus")) %>%
  full_join(Moore_WZA, by = "gene", suffix = c("_Pelorus", "_Moore")) %>%
  full_join(Lizard_WZA, by = "gene", suffix = c("_Moore", "_Lizard"))
names(merged_df)[names(merged_df) == 'Z_pVal'] <- 'Z_pVal_Lizard'

merged_df <- merged_df %>% rename(Global=Z_pVal_Global, Heron=Z_pVal_Heron, 
                   CentralOffshore=Z_pVal_CentralOffshore, Pelorus=Z_pVal_Pelorus, 
                   Moore=Z_pVal_Moore, Lizard=Z_pVal_Lizard)

long_df <- merged_df %>%
  pivot_longer(
    cols = c(Global, Lizard, Moore, Pelorus, CentralOffshore, Heron),
    names_to = "population",
    values_to = "p_value")

long_df[is.na(long_df)] <- 1
long_df <- transform(long_df, population=factor(population,levels=c("Global","Lizard","Moore", "Pelorus", "CentralOffshore", "Heron")))

long_df <- long_df %>% 
  mutate(hit = if_else(gene %in% hits$win_id, "PicMin_hit", "Not_PicMin_hit")) %>%
  mutate(significant = if_else(p_value < 0.05, "significant", "Not_significant"))  

long_df$hit_significant <- paste(long_df$hit,long_df$significant,sep="_")

# heat map top windows
merged_df <- Heron_WZA_top %>%
  full_join(CentralOffshore_WZA_top, by = "win_id", suffix = c(".Heron", ".CentralOffshore")) %>%
  full_join(Pelorus_WZA_top, by = "win_id", suffix = c(".CentralOffshore", ".Pelorus")) %>%
  full_join(Moore_WZA_top, by = "win_id", suffix = c(".Pelorus", ".Moore")) %>%
  full_join(Lizard_WZA_top, by = "win_id", suffix = c(".Moore", ".Lizard"))

wide_df <- merged_df %>%
  dplyr::select(win_id, starts_with("emp_p")) %>%
  column_to_rownames(var = "win_id")

wide_df[is.na(wide_df)] <- 1

breaks1 <- seq(0,4, by= 0.4)
col12 <- c("grey90", wes_palette("Zissou1",(length(breaks1)-2),type= "continuous"))
colnames(wide_df) <- c("Heron","CentralOffshore","Pelorus","Moore", "Lizard")
   
heatmap.2(as.matrix(-log10(wide_df)), trace= "none", Colv= F, Rowv= T, dendrogram= "none", 
           labRow= F, key= T, col= col12, breaks= breaks1, density.info= "none", key.title= "", 
           key.xtickfun= function() {
              breaks <- parent.frame()$breaks
              return(list(
              at=parent.frame()$scale01(c(breaks[1], breaks[length(breaks)])), labels=c(as.character(breaks[1]),
              as.character(breaks[length(breaks)]))))}, 
           key.xlab= "-log10(p value)", cexCol = 1, 
          lmat=rbind(c(6, 4, 2), c(5, 1, 3)), lhei=c(2.5, 10), lwid=c(1, 2, 1),
          key.par=list(mar=c(3.5,0,3,0)),
          margins=c(8,0))

#### Picmin ####
picmin_results <- readRDS("picMin_results.rds")

names(picmin_results)[names(picmin_results) == 'window'] <- 'win_id'

picmin_results <- picmin_results %>%
  mutate(window_num = as.numeric(gsub("wind_", "", win_id))) %>%
  arrange(window_num)

snp_windows <- read.table("snp_windows.txt", header = TRUE)
split_values <- do.call(rbind, strsplit(as.character(snp_windows$snp_id), ":"))
snp_windows$scaffold <- split_values[, 1]
snp_windows$position <- as.numeric(split_values[, 2])
#n_distinct(snp_windows$scaffold) # nb of scaffolds included in 10kb windows = 3915

# plot
setDT(snp_windows)
setDT(picmin_results)
snp_summary <- snp_windows[, .SD[1], by = win_id, .SDcols = c("scaffold", "position")]

picmin_results[, win_id := paste0("wind_", window_num)]
picmin_coords <- snp_summary[picmin_results, on = .(win_id)]
picmin_coords <- mapping_df[picmin_coords, on = .(contig = scaffold)]

picmin_coords[, chrom_pos := ifelse(
  strand == "+",
  chrom_start + position - contig_start,
  chrom_end - position + contig_start
)]

ggplot(picmin_coords, aes(x = chrom_pos, y = -log10(q), fill = factor(n_est))) +
  geom_point(shape = 21, size = 3) +
  geom_hline(aes(yintercept = -log10(0.5)), lty = 2) +
  scale_fill_manual(values = c("rosybrown2", "rosybrown3", "lightpink4", "hotpink4")) +
  facet_grid(cols = vars(chrom), space = "free_x", scales = "free_x", switch = "x") +
  theme_bw() +
  theme(
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 10),
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    panel.spacing = unit(0.1, "cm")
  ) +
  labs(y = "-log10(q)")

# hits
FDR=0.5
p=0.05

hits <- picmin_results[picmin_results$pooled_q<FDR,] # 9 hits
hits <- hits %>% arrange(-pooled_q)
hits$window <- factor(hits$window, levels = hits$window)

# how many hits for 2,3,4 or 5 pops?
sum(hits$n_est == "3") #5
sum(hits$n_est == "4") #4
sum(hits$n_est == "5") #0

# plot windows ~ q and ~ n_est
ggplot(hits, aes(x = -log10(pooled_q), y = reorder(win_id, -log10(pooled_q)))) +
       geom_bar(stat = "identity", fill = "gray30") +
       labs(x = "-log10(q)", y = "window") +
       theme_gray() +
       theme(axis.text.y = element_text(size = 8)) +
       theme_bw()

ggplot(hits, aes(x = n_est, y = reorder(win_id, -log10(pooled_q)))) +
  geom_bar(stat = "identity", fill = "gray30") +
  labs(x = "number of populations", y = "window") +
  theme_gray() +
  theme(axis.text.y = element_text(size = 8)) +
  theme_bw()

#### PicMin score vs WZA score ####
Lizard_WZA_PicMin <- Lizard_WZA %>% full_join(picmin_results, by = "win_id")
Moore_WZA_PicMin <- Moore_WZA %>% full_join(picmin_results, by = "win_id")
CentralOffshore_WZA_PicMin <-CentralOffshore_WZA %>% full_join(picmin_results, by = "win_id")
Heron_WZA_PicMin <- Heron_WZA %>% full_join(picmin_results, by = "win_id")
Pelorus_WZA_PicMin <- Pelorus_WZA %>% full_join(picmin_results, by = "win_id")

plot(-log10(Pelorus_WZA_PicMin$q), -log10(Pelorus_WZA_PicMin$emp_p))
abline(v=-log10(0.5), col="red")

#### Mapping WZA result to RagTag ####

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

# from saved files         
mapping_df <- readRDS("mapping_df.rds")   
snp_windows <- readRDS("snp_windows.rds") 
long_df     <- readRDS("long_df.rds")     

snp_summary <- snp_windows[, .SD[1], by = win_id, .SDcols = c("scaffold", "position")]
long_df_coords <- snp_summary[long_df, on = .(win_id = gene)]
long_df_coords <- mapping_df[long_df_coords, on = .(contig = scaffold)]

long_df_coords[, chrom_pos := ifelse(
  strand == "+",
  chrom_start + position - contig_start,
  chrom_end - position + contig_start
)]

long_df_coords <- long_df_coords %>%
  mutate(
    chrom_color = ifelse(as.numeric(factor(chrom)) %% 2 == 0, "grey10", "grey40"),
    point_color = ifelse(hit_significant == "PicMin_hit_significant", "maroon", chrom_color)
  )

png("manhattan_plot_colored_chrom.png", width = 12, height = 8, units = "in", res = 300)

ggplot(long_df_coords, aes(x = chrom_pos, y = -log10(p_value), color = point_color)) +
  geom_point(size = 2, alpha = 0.8) +
  facet_grid(rows = vars(population), cols = vars(chrom), space = "free_x", scales = "free_x", switch = "x") +
  geom_vline(
    data = subset(long_df_coords, hit_significant == "PicMin_hit_significant"),
    aes(xintercept = chrom_pos),
    color = "maroon", linetype = "solid", alpha = 0.8, size = 1
  ) +
  scale_color_identity() +
  theme_classic() +
  theme(
    legend.position = "none",
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    panel.spacing = unit(0.1, "cm")
  ) +
  labs(y = "-log10(p-value)")

dev.off()
