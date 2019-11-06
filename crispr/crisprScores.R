args =  commandArgs(TRUE)
fileName=args[1]
outFile=args[2]
group<-args[3]
if (file.exists(fileName) == FALSE || length(args) != 3){
  writeLines ("Usage:\nRscript crisprQC.R countsFile outFileBaseName groups<colon-sep>\n");
  writeLines ("groups is colon separated list of group corresponding to each sample\n");
  quit()
}

library(edgeR)
options(stringsAsFactors=F)

d <- read.delim(fileName, check.names = F)
anno <- d[,c(1:3)]
anno <- unique(anno)
d <- d[,c(1, 4:ncol(d))]
d<-unique(d)
d<-data.frame(d[2:ncol(d)], row.names=d$ID, check.names=F)

group <- strsplit(group,":")[[1]]
targets <- data.frame(Sample = names(d),
                      Group = group)
d <- d[,targets$Sample]

#group<-targets$Group
d[is.na(d)] <- 0
d<-DGEList(counts=d,group=group)
table(targets$Group)
minNumberOfReps<-1
d <- d[rowSums(1e+06 * d$counts/expandAsMatrix(d$samples$lib.size, dim(d)) > 1) >= minNumberOfReps, ]; 
d <- calcNormFactors(d)
d$samples

nd<-cpm(d, normalized.lib.sizes=TRUE, log=FALSE); nd<-data.frame(nd, check.names=F)
#add psuedocount of 1 to all values
nd<-nd+1

nd$P0 <- apply(nd[1:3], 1, mean)
#nd$FHSC14_p0 <- apply(nd[4:5], 1, mean)

nd <- nd[,c(ncol(nd),5:ncol(nd)-1)]
x <- nd
x[2:ncol(x)] <- x[2:ncol(x)]/x$P0
#x[3:6] <- x[3:6]/x$FHSC04_p0
#x[7:12] <- x[7:12]/x$RU280_P0
#discard p0 columns
x <- data.frame(x[2:ncol(x)], check.names = F)
x<-log2(x)

#add gene and guide annotation, then calculate average log2 ratio for each gene
m<-data.frame(row.names(x),x, check.names=F); names(m)[1]<-"ID"
m<-merge(anno,m,by="ID", all.y=T); nrow(m) #122783
m<-m[grep("NTC", m$Gene, invert=T),]; nrow(m) #120787
m<-data.frame(m[3],m[4:ncol(m)], check.names=F)
m <- unique(m); nrow(m) #120760
m<-m[order(m$Gene),]
numberOfGuidesPerGene<-data.frame(table(m$Gene)); names(numberOfGuidesPerGene)<-c("Gene","guides"); nrow(numberOfGuidesPerGene) #20915
z<-aggregate(. ~ Gene,m,mean); nrow(z) #20915
z<-merge(numberOfGuidesPerGene, z, by="Gene"); nrow(z)
#names(z)[1]<-"gene"
write.table(z, file=paste0(outFile,"_crisprScores.txt"),sep="\t",quote=F,row.names=F)

#CRISPR Score plots
d <- z
for(i in 3:ncol(d)){
pdf(file=paste0(names(d)[i],"_CRISPRscorePlot.pdf"))
x<-d[,i][order(d[,i], decreasing = F)]
plot(1:length(x),x, type="l", xaxt="n", main=names(d)[i],
     xlab="Genes ranked by CRISPR score", ylab="CRISPR gene score (mean sgRNA)")
dev.off()
}
