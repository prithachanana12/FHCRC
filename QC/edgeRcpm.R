args =  commandArgs(TRUE)
fileName=args[1]
outFile=args[2]
if (file.exists(fileName) == FALSE || length(args) != 2){
  writeLines ("Usage:\nRscript edgeRcpm.R fileName path_to_outfile\n");
  quit()
}

library(edgeR)

dat <- read.table(fileName,sep="\t",header=TRUE,row.names=1)
group <- c(rep("pos",2),rep("neg",2),"pos","neg")

cds <- DGEList(dat,group=group)
cds <- calcNormFactors(cds)
logCPM <- cpm(cds,log=TRUE)
head(logCPM)
write.table(logCPM, file=outFile, sep="\t",row.names=TRUE)
