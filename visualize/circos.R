args =  commandArgs(TRUE)
fileName=args[1]
out_png=args[2]
if (file.exists(fileName) == FALSE || length(args) != 2){
  writeLines ("Usage:\nRscript circos.R filePath outFilePath\n");
  quit()
}

library(BioCircos)
library(RColorBrewer)

my_palette <- c(brewer.pal(11,"Spectral"))

dat <- read.table(fileName, header=TRUE)

NP1 <- subset(dat, ProgressionStatus=="NP" & count==1)
NP2 <- subset(dat, ProgressionStatus=="NP" & count==2)
NP3 <- subset(dat, ProgressionStatus=="NP" & count==3)
NP4 <- subset(dat, ProgressionStatus=="NP" & count==4)

#creating the first plot
png(out_png, height=8, width=8, units="in", res=800)
tracks_np <- BioCircosLinkTrack("np_1",NP1$chr1,NP1$pos1,NP1$pos1 + 1, NP1$chr2, NP1$pos2, NP1$pos2 + 1, maxRadius = 1, color="gray", width=0.7)
tracks_np <- tracks_np + BioCircosLinkTrack("np_2", NP2$chr1,NP2$pos1,NP2$pos1 + 1, NP2$chr2, NP2$pos2, NP2$pos2 + 1, maxRadius = 1, color=my_palette[10], width=0.9)
tracks_np <- tracks_np + BioCircosLinkTrack("np_3", NP3$chr1,NP3$pos1,NP3$pos1 + 1, NP3$chr2, NP3$pos2, NP3$pos2 + 1, maxRadius = 1, color=my_palette[5], width=1.1)
tracks_np <- tracks_np + BioCircosLinkTrack("np_4", NP4$chr1,NP4$pos1,NP4$pos1 + 1, NP4$chr2, NP4$pos2, NP4$pos2 + 1, maxRadius = 1, color=my_palette[1], width = 1.3)
BioCircos(tracks_np, genomeFillColor = "Set1", genomeTicksTextSize = 0, genomeTicksScale = 10e+06)
dev.off()
