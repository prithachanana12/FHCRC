args =  commandArgs(TRUE)
countsDir=args[1]
outFile=args[2]
if (file.exists(countsDir) == FALSE || length(args) != 2){
  writeLines ("Usage:\nRscript mergeCounts.R countsDir outFileBaseName\n");
  quit()
}

#library(edgeR)
options(stringsAsFactors = F)

setwd(countsDir)
#todaysDate<-substr(format(Sys.time(), "%Y.%m.%d."),1,11)
#get number of detected gRNAs from each sample
countsFiles<-dir(pattern="*.counts$")
for(i in countsFiles){
  d<-read.delim(i); print(paste(i,": ", nrow(d),sep=""))
}

fnames<-dir(pattern="*.counts")
merged<-read.delim(fnames[length(fnames)])
names(merged)<-c("Gene",gsub(".counts","",fnames[length(fnames)]))
for(f in fnames[(length(fnames)-1):1]){
  d<-read.delim(f)
  names(d)<-c("Gene",sub(".counts","",f))
  merged<-merge(d,merged, by="Gene", all.x=TRUE, all.y=TRUE)
}
merged[is.na(merged)]<-0
write.table(merged,file=paste0(outFile,"_counts.txt"),sep="\t",quote=F,row.names=F)

pdf(file=paste(outFile,"_RawCountsHistograms.pdf",sep=""), width=12, height=12)
par(mfrow=c(3,3))
for(i in countsFiles){
  d<-read.delim(i); print(paste(i,": ", nrow(d),sep=""))
  sampleName<-gsub(".counts","",i)
  hist(log10(d$Freq), breaks=seq(0,8,l=45), main=sampleName, xlab="log10(counts)", ylab="sgRNAs", xlim=c(0,7)) #, ylim=c(0,30000))
}
dev.off()

