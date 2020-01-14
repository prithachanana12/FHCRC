args =  commandArgs(TRUE)
fileName=args[1]
outFile=args[2]
if (file.exists(fileName) == FALSE || length(args) != 2){
  writeLines ("Usage:\nRscript syntheticNTC.R NTC_ID_list outFileName\n");
  quit()
}

library(dplyr)
library(tidyr)
library(tibble)
options(stringsAsFactors = F)

controls <- read.delim(fileName, header = F, stringsAsFactors = F)
NTC_new <- list()
for (i in 1:1906){NTC_new[i] <- list(sample(controls$V1, size=8, replace = F))}
dd  <-  as.data.frame(matrix(unlist(NTC_new), nrow=length(unlist(NTC_new[1]))))
colnames(dd) <- paste0("NTC_new_",1:1906)
dd <- t(dd)
dd<- rownames_to_column(as.data.frame(dd),"GeneName")
dd_new <- gather(dd,key = "key", value = "sgrnaID", V1:V8)
dd_new <- gather(dd,key = "key", value = "sgrnaID", V1:V8) %>% select(-key)
write.table(dd_new,outFile,quote=F,sep="\t",row.names=F)
