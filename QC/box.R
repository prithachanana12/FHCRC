args =  commandArgs(TRUE)
fileRaw=args[1]
fileNorm=args[2]
outFile=args[3]
if (file.exists(fileRaw) == FALSE || file.exists(fileNorm) == FALSE || length(args) < 3){
  writeLines ("Usage:\nRscript box.R fileRaw fileNorm outFile_basename\n");
  quit()
}

raw <- read.table(fileRaw, header=T,row.names=1)
norm <- read.table(fileNorm, header=T, row.names=1)

raw.log <- log2(raw+1)
png(paste0(outFile,".box.raw.png"),width=7,height=9,units="in",res=800)
boxplot(raw.log[1:length(raw.log)], names=colnames(raw)[1:length(raw)], xlab="Samples", ylab="log2(RawCounts)", las=2, cex.axis=0.6)
dev.off()

norm.log <- log2(norm+1)
png(paste0(outFile,".box.norm.png"),width=7,height=9,units="in",res=800)
boxplot(norm.log[1:length(norm.log)], names=colnames(norm)[1:length(norm)], xlab="Samples", ylab="log2(NormCounts)", las=2, cex.axis=0.6)
dev.off()
