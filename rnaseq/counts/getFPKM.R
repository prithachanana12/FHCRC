args =  commandArgs(TRUE)
fileName=args[1]
outFile=args[2]
if (file.exists(fileName) == FALSE || length(args) != 2){
  writeLines ("Usage:\nRscript getFPKM.R filePath controlName numSamplesInControl caseName numSamplesIncase\n");
  writeLines ("The input file should have first column of chr@gene@start@stop and second column should be gene length followed by all raw counts columns\n");
  quit()
}
dat <- read.table(fileName, header=TRUE, row.names=1, sep="\t")
libSize <- apply(dat[2:ncol(dat)], 2, sum)
scalingFac <- libSize / 1000000
dat.FPM <- sweep(dat[2:ncol(dat)],2,scalingFac,'/')
dat.FPKM <- sweep(dat.FPM, 1, dat$CodingLength, '/')
write.table(dat.FPKM,outFile, quote = FALSE, row.names = TRUE, sep="\t", col.names = TRUE)
