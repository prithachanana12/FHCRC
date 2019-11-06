args =  commandArgs(TRUE)
fileName=args[1]
outFile=args[2]
n=args[3]
if (file.exists(fileName) == FALSE || length(args) != 3){
  writeLines ("This script filters the counts tables for MAGeCK analysis to top N guides per gene. The guides with the highest average counts across all samples are kept.");
  writeLines ("Usage:\nRscript topN_guides.R input_counts_file outputFile N(number of guides from each gene to keep)\n");
  quit()
}

library(dplyr)

dat <- read.table(fileName, header=TRUE, sep="\t")
dat <- dat %>% mutate(avgCnts=rowMeans(select(., starts_with("s4")))) %>% group_by(gene)
dat.new <- dat %>% top_n(4,avgCnts) %>% select(-avgCnts)
write.table(dat.new, file=outFile, sep="\t", quote=FALSE, row.names=FALSE)
