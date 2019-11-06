args =  commandArgs(TRUE)
inFile=args[1]
outFile=args[2]
if (file.exists(inFile) == FALSE || length(args) != 2){
  writeLines ("Usage:\nRscript DE_postProcess.R inFile outFile\n");
  quit()
}

library(dplyr)

tab <- read.table(inFile,sep="\t",header=T)
head(tab)
tab2 <- tab %>% group_by(sgRNA) %>% mutate(Genes=paste(GeneSymbol,collapse=", ")) %>% select(-GeneSymbol) %>% distinct()
head(tab2)
write.table(tab2,outFile,sep="\t",row.names=F)
