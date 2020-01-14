args =  commandArgs(TRUE)
fileName=args[1]
outFile=args[2]
if (file.exists(fileName) == FALSE || length(args) < 2){
  writeLines ("Usage:\nRscript volcano.R fileName outFile_basename\n");
  quit()
}

library(ggplot2)
library(ggrepel)
library(dplyr)
library(stringr)

dat <- read.table(fileName, sep='\t', header=T)
dat$threshf <- as.factor(abs(dat$LFC)>1.5 & dat$FDR <= 0.05)
#dat$mult <- as.factor(str_detect(dat$Genes,","))
#pos <- dat %>% filter(logFC > 1.5 & FDR <= 0.05  & mult == F) %>% top_n(-10, FDR)
#neg <- dat %>% filter(logFC < -1.5 & FDR <= 0.05  & mult == F) %>% top_n(-10, FDR)
pos <- dat %>% filter(LFC > 1.5 & FDR <= 0.05) %>% top_n(-10, FDR)
neg <- dat %>% filter(LFC < -1.5 & FDR <= 0.05) %>% top_n(-10, FDR)
volcanof <- ggplot(data=dat, aes(x=LFC, y=(-log10(FDR)), color=threshf))+ theme(legend.position = "none") + geom_point(alpha=0.4, size=1.75) + xlab("log 2 Fold Change") + ylab("-log10 FDR")+ geom_text_repel(aes(label=ifelse(dat$sgrna %in% pos$sgrna | dat$sgrna %in% neg$sgrna,as.character(sgrna),'')),size=2.5)
ggsave(paste(outFile,"_fdr.png",sep=""))
