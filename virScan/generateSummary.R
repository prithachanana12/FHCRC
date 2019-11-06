todaysDate <- substr(format(Sys.time(), "%Y.%m.%d."),1,11)
flowCell <- "190814_SN367_1421_BH3G2JBCX3"

###summarize counts
setwd("/fh/fast/_SR/Genomics/user/pchanana/2019.06.04.tsayers/results/count")
options(stringsAsFactors = F)
fnames<-dir(pattern="count.csv.gz")
zz<-gzfile(fnames[1], 'rt'); d<-read.csv(zz, check.names=F)
names(d)[2] <- sub(".count.csv.gz", "", fnames[1])
for(f in 2:length(fnames)){
  zz<-gzfile(fnames[f], 'rt'); x<-read.csv(zz, check.names=F); print(nrow(x))
  names(x)[2] <- sub(".count.csv.gz", "", fnames[f])
  d<-merge(d,x,by="id"); print(nrow(d))
}
write.table(d, file=paste0("/fh/fast/_SR/Genomics/user/pchanana/2019.06.04.tsayers/summary/", todaysDate, "counts.txt"),sep="\t",quote=F,row.names=F)


###summary stats
d<-data.frame(d[2:ncol(d)], row.names=d$id, check.names=F)
Sums<-apply(d,2,sum)
hasCounts<-function(x){
  length(x[x > 0])
}
OligosDetected<-apply(d,2,hasCounts); OligosDetected
#Just curious what % of the clones are not detected? and what % of the clones lie between 10 and 100 reads
between10and100<-function(x){
  length(x[x > 10 &  x < 100])
}
lessThan100gt10<-apply(d,2,between10and100)
z<-cbind(OligosDetected,lessThan100gt10)
z<-data.frame(z)
z$PercentDetected<-100*round(OligosDetected/96179,4)
z$PercentBetween10and100<-100*round(lessThan100gt10/96179,4)
names(z)[1:2]<-c("Detected","Between10and100")
z<-data.frame(row.names(z),z); names(z)[1]<-"Sample"
#add number of aligned reads to detection summary
x <- data.frame(Sums, check.names=F)
x <- data.frame(Sample = row.names(x),
                AlignedReads = x$Sums)
z<-merge(z, x, by = "Sample"); nrow(z)
z <- z[,!names(z) %in% "AlignedReads.y"]
names(z) <- sub("AlignedReads.x", "AlignedReads", names(z))
write.table(z, file = paste0("/fh/fast/_SR/Genomics/user/pchanana/2019.06.04.tsayers/summary/", todaysDate, "detectionSummary.txt"),sep="\t",quote=F,row.names=F)
setwd("/fh/fast/_SR/Genomics/user/pchanana/2019.06.04.tsayers/summary/")
demuxStats <- read.delim("tsayers.demux.stats.txt", check.names = F); nrow(demuxStats) #386
demuxStats <- demuxStats[,!names(demuxStats) %in% c("Sample Ref", "Index", "Description", "Control", "Yield (Mbases)", "Project")]
demuxStats$`Sample ID` <- sub("_rep1$", ".rep1", demuxStats$`Sample ID`)
demuxStats$`Sample ID` <- sub("_rep2$", ".rep2", demuxStats$`Sample ID`)
m <- merge(z, demuxStats, by.x = "Sample", by.y = "Sample ID"); nrow(m) #384
write.table(m, file = paste0(todaysDate, "demultiplexingAndAlignmentSummary.txt"), sep = "\t", quote = F, row.names = F)


###Generate combined scores and combined hits files, separately for SABES and non-SABES
sampleSheet <- data.frame(Sample = m$Sample, Lane = m$Lane)
sampleSheet$Sample <- sub(".rep[1-2]$", "", sampleSheet$Sample); sampleSheet <- unique(sampleSheet)
sabes <- sampleSheet$Sample[grep("SABES", sampleSheet$Sample)]
others <- sampleSheet$Sample[grep("SABES", sampleSheet$Sample, invert = TRUE)]
others <- others[-length(others)] ##to remove the 'library' sample - command doesn't work every time, depends on the names of the other samples

#combined hits
setwd("/fh/fast/_SR/Genomics/user/pchanana/2019.06.04.tsayers/results/zihit")
fnames <- paste0(sabes, ".zihit.csv.gz")
info <- file.info(fnames)
empty <- rownames(info[info$size <= 45, ])
fnames <- fnames[!fnames %in% empty]
zz<-gzfile(fnames[1], 'rt'); d<-read.csv(zz, check.names=F)
for(f in 2:length(fnames)){
  zz<-gzfile(fnames[f], 'rt'); x<-read.csv(zz, check.names=F); print(nrow(x))
  d<-merge(d,x,by="id"); print(nrow(d))
}
write.table(d, file = paste0("/fh/fast/_SR/Genomics/user/pchanana/2019.06.04.tsayers/summary/", todaysDate, "zihits_SABES.txt"),sep="\t",quote=F,row.names=F)
fnames <- paste0(others, ".zihit.csv.gz")
info <- file.info(fnames)
empty <- rownames(info[info$size <= 45, ])
fnames <- fnames[!fnames %in% empty]
zz<-gzfile(fnames[1], 'rt'); d<-read.csv(zz, check.names=F)
for(f in 2:length(fnames)){
  zz<-gzfile(fnames[f], 'rt'); x<-read.csv(zz, check.names=F); print(nrow(x))
  d<-merge(d,x,by="id"); print(nrow(d))
}
write.table(d, file = paste0("/fh/fast/_SR/Genomics/user/pchanana/2019.06.04.tsayers/summary/", todaysDate, "zihits_IDS.txt"),sep="\t",quote=F,row.names=F)

#combined scores
setwd("/fh/fast/_SR/Genomics/user/pchanana/2019.06.04.tsayers/results/ziscore")
fnames <- paste0(sabes, ".ziscore.spp.csv.gz")
info <- file.info(fnames)
empty <- rownames(info[info$size <= 51, ])
fnames <- fnames[!fnames %in% empty]
zz<-gzfile(fnames[1], 'rt'); d<-read.csv(zz, check.names=F)
for(f in 2:length(fnames)){
  zz<-gzfile(fnames[f], 'rt'); x<-read.csv(zz, check.names=F); print(nrow(x))
  d<-merge(d,x,by="Species", all.x = TRUE); print(nrow(d))
}
write.table(d, file = paste0("/fh/fast/_SR/Genomics/user/pchanana/2019.06.04.tsayers/summary/", todaysDate, "ziscores_SABES.txt") ,sep="\t",quote=F,row.names=F)
fnames <- paste0(others, ".ziscore.spp.csv.gz")
info <- file.info(fnames)
empty <- rownames(info[info$size <= 51, ])
fnames <- fnames[!fnames %in% empty]
zz<-gzfile(fnames[1], 'rt'); d<-read.csv(zz, check.names=F)
for(f in 2:length(fnames)){
  zz<-gzfile(fnames[f], 'rt'); x<-read.csv(zz, check.names=F); print(nrow(x))
  d<-merge(d,x,by="Species", all.x = TRUE); print(nrow(d))
}
write.table(d, file = paste0("/fh/fast/_SR/Genomics/user/pchanana/2019.06.04.tsayers/summary/", todaysDate, "ziscores_IDS.txt") ,sep="\t",quote=F,row.names=F)

#combined zipvals
sampleSheet <- data.frame(Sample = m$Sample, Lane = m$Lane)
setwd("/fh/fast/_SR/Genomics/user/pchanana/2019.06.04.tsayers/results/zipval")
fnames <- paste0(sampleSheet$Sample, ".zipval.csv.gz")
fnames <- fnames[grep("SABES", fnames)]
info <- file.info(fnames)
empty <- rownames(info[info$size <= 51, ])
fnames <- fnames[!fnames %in% empty]
zz<-gzfile(fnames[1], 'rt'); d<-read.csv(zz, check.names=F)
resultName <- sub(".zipval.csv.gz", "", fnames[1])
names(d)[2] <- resultName
for(f in 2:length(fnames)){
  zz<-gzfile(fnames[f], 'rt'); x<-read.csv(zz, check.names=F); print(nrow(x))
  resultName <- sub(".zipval.csv.gz", "", fnames[f])
  names(x)[2] <- resultName
  d<-merge(d,x,by="id", all.x = TRUE); print(nrow(d))
}
write.table(d, file = paste0("/fh/fast/_SR/Genomics/user/pchanana/2019.06.04.tsayers/summary/", todaysDate, "zipvals_SABES.txt") ,sep="\t",quote=F,row.names=F)
fnames <- paste0(sampleSheet$Sample, ".zipval.csv.gz")
fnames <- fnames[grep("SABES", fnames, invert = TRUE)]
fnames <- fnames[-length(fnames)] ##remove 'library' sample, depends on the sample names if this command will work or will need to be tweaked
info <- file.info(fnames)
empty <- rownames(info[info$size <= 51, ])
fnames <- fnames[!fnames %in% empty]
zz<-gzfile(fnames[1], 'rt'); d<-read.csv(zz, check.names=F)
resultName <- sub(".zipval.csv.gz", "", fnames[1])
names(d)[2] <- resultName
for(f in 2:length(fnames)){
  zz<-gzfile(fnames[f], 'rt'); x<-read.csv(zz, check.names=F); print(nrow(x))
  resultName <- sub(".zipval.csv.gz", "", fnames[f])
  names(x)[2] <- resultName
  d<-merge(d,x,by="id", all.x = TRUE); print(nrow(d))
}
write.table(d, file = paste0("/fh/fast/_SR/Genomics/user/pchanana/2019.06.04.tsayers/summary/", todaysDate, "zipvals_IDS.txt") ,sep="\t",quote=F,row.names=F)
