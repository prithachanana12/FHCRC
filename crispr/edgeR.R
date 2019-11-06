args =  commandArgs(TRUE)
fileName=args[1]
control=args[2]
num_of_ctrl=args[3]
case=args[4]
num_of_case=args[5]
outdir=args[6]
outFile=args[7]
if (file.exists(fileName) == FALSE || length(args) < 7){
  writeLines ("Usage:\nRscript  edgeR.R filePath controlName numSamplesInControl caseName numSamplesIncase outdir outFileBaseName\n");
  quit()
}

library(edgeR)
library(dplyr)
#library(ggplot2)
#library(ggrepel)
options(stringsAsFactors = F)
#todaysDate<-substr(format(Sys.time(), "%Y.%m.%d."),1,11)
setwd(outdir)

#anno <- read.delim("/fh/fast/_SR/Genomics/user/pchanana/2019.08.15.lcarter/annotation/2019.02.06.CPD_annotation.txt"); nrow(anno)

d<-read.delim(file=fileName, stringsAsFactors=F); nrow(d) #117898
d<-data.frame(d[2:ncol(d)], row.names=d$Gene)
d[is.na(d)]<-0

targets <- data.frame(Sample = names(d),
                      Group = c(rep(control,num_of_ctrl),
                                rep(case, num_of_case)))
targets<-targets[order(targets$Group, targets$Sample),]
group<-targets$Group
d<-d[,as.character(targets$Sample)]

d<-DGEList(counts=d,group=group)
#filter out guides with fewer than 5 CPM in at least 2 samples
selr <- rowSums(cpm(d$counts)>=5) >=2
d <- d[selr,]; nrow(d) #102048

d <- calcNormFactors(d, method = "TMM")
nd <- data.frame(cpm(d, normalized.lib.sizes = T, log = T), check.names = F)

columnOrder<-c("Gene", as.character(targets$Sample))
rawCounts<-d$counts
rawCounts<-data.frame(row.names(rawCounts),rawCounts, check.names=F); names(rawCounts)[1]<-"Gene"
rawCounts<-rawCounts[,columnOrder]
normalizedCounts<-cpm(d, normalized.lib.sizes=TRUE)
#normalizedCounts<-br
normalizedCounts<-data.frame(row.names(normalizedCounts), normalizedCounts, check.names=F); names(normalizedCounts)[1]<-"Gene"
normalizedCounts<-normalizedCounts[,columnOrder]
counts<-merge(normalizedCounts, rawCounts, by.x="Gene", by.y="Gene")
names(counts)<-gsub(".x$",".normCPM",names(counts))
names(counts)<-gsub(".y$",".raw",names(counts))

Group<-factor(targets$Group)
# Batch<-factor(targets$Source)
# design<-model.matrix(~0+Group+Batch, data=d$samples)
design<-model.matrix(~Group)
colnames(design)<-gsub("Group","",colnames(design))
y<-estimateDisp(d, design)
fit<-glmFit(y,design)
lrt<-glmLRT(fit)
resTable.tgw <- topTags( lrt , n = nrow( lrt$table ) )$table
resTable.tgw <- resTable.tgw %>% tibble::rownames_to_column(var="Gene")
resFinal <- merge(resTable.tgw, counts, by="Gene") %>% rename (sgRNA = Gene) %>% arrange(PValue)
#outFile <- paste0(todaysDate,"Z8_DE.txt")
write.table(resFinal, file=paste0(outFile,"_DE.txt"),sep="\t",row.names=F)


#MA plots
#png(file=paste0(todaysDate,"CPD_MA.png"))
#par( mfrow = c(2,1) )
#resFinal.DE <- resFinal %>% filter(FDR<=0.05 && abs(logFC)>1.5) %>%tibble::column_to_rownames(var="sgRNA")
#plotSmear( lrt , de.tags=resFinal.DE , main="Tagwise" ,allCol="black", lowCol="orange", deCol="red",pair=c("CPD_Day0","CPD_Rep"),cex = .5 ,xlab="Log Concentration" , ylab="Log Fold-Change" )
#abline( h = c(-1.5, 1.5) , col = "dodgerblue" )
#par( mfrow=c(1,1) )
#dev.off()

##Volcano plot
#png(file=paste0(todaysDate,".CPD_volcano.png"))
#dat <- resFinal
#dat$thresh <- as.factor(abs(dat$logFC)>1.5 & dat$FDR <= 0.05)
#volcanof <- ggplot(data=dat, aes(x=logFC, y=(-log10(FDR)), color=thresh))+ theme(legend.position = "none") + geom_point(alpha=0.4, size=1.75) + xlab("log 2 Fold Change") + ylab("-log10 FDR")
#ggsave(paste0(todaysDate,".CPD_volcano.png"))
