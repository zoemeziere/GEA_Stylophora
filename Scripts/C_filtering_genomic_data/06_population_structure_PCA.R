library(tidyverse)
library(dartR)
library(data.table)

#PCA

SpisTaxon1_metadata <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/metadata/WGSpisTaxon1_Metadata.csv")

setwd("/Users/zoemeziere/Documents/PhD/Chapter3_analyses/population_structure")

pca <- fread("Spis_noreplicates_badsamples_filtered_prunned.eigenvec")
eigenval <- fread("Spis_noreplicates_badsamples_filtered_prunned.eigenval")

pca <- pca[,-1]
names(pca)[1] <- "ind"
names(pca)[2:ncol(pca)] <- paste0("PC", 1:(ncol(pca)-1))

pve <- data.frame(PC = 1:10, pve = eigenval/sum(eigenval)*100)
ggplot(pve, aes(PC, V1)) + geom_bar(stat = "identity") +
  ylab("Percentage variance explained") + theme_light()
cumsum(pve$V1)

ggplot(pca, aes(PC1, PC2, fill= SpisTaxon1_metadata$EcoReefID)) + 
  geom_point(shape=21, size=4) +
  scale_fill_manual(values = c("#A2B52B", "#7BB52B", "#5CBED1", "#5C9FD1", "#1F7D1E", "#B05102", "#F39237", "#F2C738")) +
  coord_equal() + theme_bw() + theme(axis.text=element_text(size=10), axis.title=element_text(size=10)) +
  xlab(paste0("PC1 (", signif(pve$V1[1], 3), "%)")) +
  ylab(paste0("PC2 (", signif(pve$V1[2], 3), "%)"))

#IBS

setwd("/Users/zoemeziere/Desktop")

readBSM <- function(pfx, dgv=1, fid=NULL, id=NULL, bin=NULL)
{
  ## ID in {p}.id
  if(is.null(id))
    id <- paste0(pfx, ".id")
  ids <- matrix(scan(id, "", quiet=TRUE, comment.char = "#"), 2)
  if(is.null(fid))
    ids <- ids[1, ]
  else
    ids <- paste(ids[1, ], ids[2, ], sep=fid)
  N <- length(ids)
  
  ## data matrix
  if(is.null(bin))
    bin <- paste0(pfx, ".bin")
  S <- file.size(bin) # file size
  R <- matrix(.0, N, N, dimnames=list(ids, ids))
  H <- "UNK" # shape, start with unknown
  
  ## try: lower triangle w/t diagonal
  if(H == "UNK")
  {
    L <- N * (N + 1.0) / 2.0
    U <- S / L
    if(U == 4 || U == 8)
    {
      R[upper.tri(R, 1)] <- readBin(bin, 0., L, U)
      R[lower.tri(R, 0)] <- t(R)[lower.tri(R, 0)]
      H="LWD"
    }
  }
  
  ## try: lower triangle, no diagonal
  if(H == "UNK")
  {
    L <- N * (N - 1.0) / 2.0 # number of entries
    U <- S / L               # unit size
    if(U == 4 || U == 8)
    {
      R[upper.tri(R, 0)] <- readBin(bin, 0., L, U)
      R[lower.tri(R, 0)] <- t(R)[lower.tri(R, 0)]
      diag(R) <- dgv # diagnal
      H="LND"
    }
  }
  
  ## try: a squre
  if(H == "UNK")
  {
    L <- 1.0 * N * N
    U <- S / L
    if(U == 4 || U == 8)
    {
      R[ , ] <- readBin(bin, 0., L, U)
      H="SQR"
    }
  }
  
  ## fail or return
  print(data.frame(pfx=pfx, size=S, entries=L, unit=U, shape=H, N=N))
  if(H == "UNK")
    stop("unknown storage type.")
  R
}

ibs <- readBSM("Spis_all_filtered_pruned.mdist")
ibs.dist <- as.dist(ibs)
ibs.nj <- njs(ibs)
plot(ibs.nj)
ggtree(ibs.nj) + theme_tree2() + geom_tiplab(size =7)
ggsave(filename = "ibs.nj.pdf" , device = "pdf", width = 30, height = 50 , units = "in" , limitsize = FALSE)

