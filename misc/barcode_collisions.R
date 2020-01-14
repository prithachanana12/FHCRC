#This script calculates the hamming distance between all pairs of barcodes from a given sample sheet (irrespective of lane)
install.packages("DescTools")
library(DescTools)
dat <- read.table("X://fast/_SR/Genomics/user/pchanana/2019.11.17.sfine/re_demux/191105_D00300_0852_AH5FJ2BCX3_emerman_lab.csv", sep=",", header = T)
barcodes <- as.character(dat$Index)
combs <- t(combn(barcodes,2))
combs <- as.data.frame(combs, stringsAsFactors = F)
for (i in 1:nrow(combs)){
     combs$dist[i] <- as.integer(StrDist(combs[i,1],combs[i,2], method = "hamming"))
}
