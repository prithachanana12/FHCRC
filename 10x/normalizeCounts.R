args =  commandArgs(TRUE)
indir=args[1]
outFile=args[2]
if (file.exists(fileName) == FALSE || length(args) < 2){
  writeLines ("Usage:\nRscript normalizeCounts.R indir outFile_basename\n");
  writeLines ("This script converts raw 10X counts matrix from cellranger to a csv file of normalized counts obtained by Seurat's SCTransform functionality.The indir will be the location of the filtered bc matrix from cellranger.\n");
  quit()
}

library(Seurat)
library(sctransform)

dat <- Read10X(data.dir=indir)
dat.obj <- CreateSeuratObject(counts = dat)
dat.obj <- SCTransform(dat.obj)
dat.fin <- as.data.frame (GetAssayData(dat.obj,assay="SCT"))

write.table(dat.fin,outFile,row.names=T)
