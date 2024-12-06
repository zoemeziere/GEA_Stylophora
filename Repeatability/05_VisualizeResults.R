# This follows up HPC-ran correlation calculations
library(ggplot2)
library(dplyr)
library(gplots)
library(tidyverse)
library(wesanderson)

#### Thau ####
Heron_thau <- readRDS("cor_results.rds")
Heron_thau$SNP <- seq_len(nrow(Heron_thau))

ggplot(Heron_thau, aes(x= SNP, y = -log10(p_val))) + 
  geom_point(size = 2, alpha = 0.8) +
  labs(x = "SNP ID", y = "Empirical p-value")

#### WZA ####
nbWindows <- 1000

Global_WZA <- readRDS("Global_WZA.rds")
Global_WZA <- subset(Global_WZA, select = -c(WZA) )

CentralOffshore_WZA <- readRDS("CentralOffshore_WZA.rds")
CentralOffshore_WZA <- subset(CentralOffshore_WZA, select = -c(WZA) )

CentralOffshore_WZA_top <- CentralOffshore_WZA[order(CentralOffshore_WZA$emp_p), ][1:nbWindows, ]
CentralOffshore_WZA_top$Population <- "CentralOffshore"
CentralOffshore_WZA_top <- CentralOffshore_WZA_top %>% arrange(win_id)

Heron_WZA <- readRDS("Heron_WZA.rds")
Heron_WZA <- subset(Heron_WZA, select = -c(WZA) )

Heron_WZA_top <- Heron_WZA[order(Heron_WZA$emp_p), ][1:nbWindows, ]
Heron_WZA_top$Population <- "Heron"
Heron_WZA_top <- Heron_WZA_top %>% arrange(win_id)

Pelorus_WZA <- readRDS("Pelorus_WZA.rds")
Pelorus_WZA <- subset(Pelorus_WZA, select = -c(WZA) )

Pelorus_WZA_top <- Pelorus_WZA[order(Pelorus_WZA$emp_p), ][1:nbWindows, ]
Pelorus_WZA_top$Population <- "Pelorus"
Pelorus_WZA_top <- Pelorus_WZA_100 %>% arrange(win_id)

Lizard_WZA <- readRDS("Lizard_WZA.rds")
Lizard_WZA <- subset(Lizard_WZA, select = -c(WZA) )

Lizard_WZA_top <- Lizard_WZA[order(Lizard_WZA$emp_p), ][1:nbWindows, ]
Lizard_WZA_top$Population <- "Lizard"
Lizard_WZA_top <- Lizard_WZA_top %>% arrange(win_id)

Moore_WZA <- readRDS("Moore_WZA.rds")
Moore_WZA <- subset(Moore_WZA, select = -c(WZA) )

Moore_WZA_top <- Moore_WZA[order(Moore_WZA$emp_p), ][1:nbWindows, ]
Moore_WZA_top$Population <- "Moore"
Moore_WZA_top <- Moore_WZA_top %>% arrange(win_id)

# Faceted plots
merged_df <- Global_WZA %>%
  full_join(Heron_WZA, by = "win_id", suffix = c("_Global", "_Heron")) %>%
  full_join(CentralOffshore_WZA, by = "win_id", suffix = c("_Heron", "_CentralOffshore")) %>%
  full_join(Pelorus_WZA, by = "win_id", suffix = c("_CentralOffshore", "_Pelorus")) %>%
  full_join(Moore_WZA, by = "win_id", suffix = c("_Pelorus", "_Moore")) %>%
  full_join(Lizard_WZA, by = "win_id", suffix = c("_Moore", "_Lizard"))
names(merged_df)[names(merged_df) == 'emp_p'] <- 'emp_p_Lizard'

merged_df <- merged_df %>% rename(Global=emp_p_Global, Heron=emp_p_Heron, 
                   CentralOffshore=emp_p_CentralOffshore, Pelorus=emp_p_Pelorus, 
                   Moore=emp_p_Moore, Lizard=emp_p_Lizard)

long_df <- merged_df %>%
  pivot_longer(
    -win_id,  # Columns with empirical p-values
    names_to = "population",    # Name for the new variable indicating column names
    values_to = "p_value") %>%  # Name for the new variable holding the values
  mutate(hit = if_else(win_id %in% hits$win_id, "PicMin hit", "Not PicMin hit"))        

long_df[is.na(long_df)] <- 1
long_df <- transform(long_df, population=factor(population,levels=c("Global","Lizard","Moore", "Pelorus", "CentralOffshore", "Heron")))

ggplot(long_df, aes(x = win_id, y = -log10(p_value), color = hit)) +
  geom_point(size = 2, alpha = 0.8) +
  facet_wrap(~ population, ncol = 1, strip.position="right") +
  scale_color_manual(
    values = c("PicMin hit" = "red", "Not PicMin hit" = "black"),
    guide = guide_legend(title = "PicMin hit window")) +
  geom_vline(
    data = hits, 
    aes(xintercept = win_id), 
    color = "red", alpha = 0.5) +
  theme_minimal() +
  labs(x = "Window ID", y = "Empirical p-value")

# Heat map top windows
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

# At the population level
WZ_results <- readRDS("Moore_WZA.rds")
WZ_results <- readRDS("Moore_WZA_1kb.rds")

WZ_results <- WZ_results[order(as.numeric(gsub("wind_", "", WZ_results$win_id))), ]
WZ_results$window <- seq_len(nrow(WZ_results))
plot(WZ_results$window, -log10(WZ_results$emp_p))

#### Picmin ####
picmin_results <- readRDS("picmin_results.rds")
picmin_results <- readRDS("picmin_results_1kb.rds")

names(picmin_results)[names(picmin_results) == 'window'] <- 'win_id'

picmin_results <- picmin_results %>%
  mutate(window_num = as.numeric(gsub("wind_", "", win_id))) %>%
  arrange(window_num)

snp_windows <- read.table("snp_windows.txt", header = TRUE)
snp_windows <- read.table("snp_windows_1kb.txt", header = TRUE)

split_values <- do.call(rbind, strsplit(as.character(snp_windows$snp_id), ":"))
snp_windows$scaffold <- split_values[, 1]
snp_windows$position <- as.numeric(split_values[, 2])
n_distinct(snp_windows$scaffold) # nb of scaffolds included in 10kb windows = 3915

# order by scaffold size
scaffold_lengh<- read.table("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/vcf_files/scaffold_lengh.txt", header = F )
names(scaffold_lengh)[names(scaffold_lengh) == 'V1'] <- 'scaffold'
names(scaffold_lengh)[names(scaffold_lengh) == 'V2'] <- 'lenght'

picmin_results_lengh <- picmin_results %>%
  inner_join(snp_windows, by = "win_id")

picmin_results_lengh <- picmin_results_lengh %>%
  inner_join(scaffold_lengh, by = "scaffold")

picmin_results_lengh <- picmin_results_lengh %>%
  arrange(desc(lenght), position)

FDR=0.5
p=0.005

# plots
ggplot(data = picmin_results, 
       aes(x = window_num, y = -log10(q), fill = factor(n_est)))+
  geom_point(shape = 21, size = 5)+
  geom_hline(aes(yintercept = -log10(FDR)), lty=2) +
  scale_fill_manual(values = c("gray90", "gray70", "gray60", "grey30", "grey1")) +
  theme_bw() + theme(axis.text=element_text(size=10), axis.title=element_text(size=10))

ggplot(data = picmin_results_lengh, 
       aes(x = window, y = -log10(p), fill = factor(n_est)))+
  geom_point(shape = 21, size = 5)+
  geom_hline(aes(yintercept = -log10(0.005)), lty=2)

# hits
hits <- picmin_results[picmin_results$q<FDR,]
hits <- hits %>% arrange(-q)
hits$window <- factor(hits$window, levels = hits$window)
hits <- merge(hits, snp_windows, by.x = "window", by.y = "win_id", all.x = TRUE)

hitsP <- picmin_results[picmin_results$p<p,]
hitsP <- hitsP %>% arrange(-p)
hitsP$window <- factor(hitsP$window, levels = hitsP$window)
hitsP <- merge(hitsP, snp_windows, by.x = "window", by.y = "win_id", all.x = TRUE)

#how many SNPs per window?
numberSNPs <- hitsP %>%
  group_by(window) %>%
  summarise(snp_count = n())

ggplot(hits, aes(x = -log10(q), y = window)) +
  geom_col()

ggplot(hits, aes(x = n_est, y = window)) +
  geom_col()

#### PicMin score vs WZA score ####
Lizard_WZA_PicMin <- Lizard_WZA %>% full_join(picmin_results, by = "win_id")
Moore_WZA_PicMin <- Moore_WZA %>% full_join(picmin_results, by = "win_id")
CentralOffshore_WZA_PicMin <-CentralOffshore_WZA %>% full_join(picmin_results, by = "win_id")
Heron_WZA_PicMin <- Heron_WZA %>% full_join(picmin_results, by = "win_id")
Pelorus_WZA_PicMin <- Pelorus_WZA %>% full_join(picmin_results, by = "win_id")

plot(-log10(Pelorus_WZA_PicMin$q), -log10(Pelorus_WZA_PicMin$emp_p))
abline(v=-log10(0.5), col="red")
