args =  commandArgs(TRUE)
fileName=args[1]
control=args[2]
num_of_ctrl=args[3]
case=args[4]
num_of_case=args[5]
if (file.exists(fileName) == FALSE){
  writeLines ("Usage:\nRscript  edgeR_pipe.R filePath controlName numSamplesInControl caseName numSamplesIncase\n");
  quit()
}

#source("http://www.bioconductor.org/biocLite.R")
#biocLite("edgeR")
library(edgeR)

##read-in the data and groups
data=read.table(file=fileName, header=TRUE)
counts=data[,-c(1,1)]
rownames(counts)=data[,1]
group <- c(rep(control, num_of_ctrl) , rep(case, num_of_case))

cds=DGEList(counts, group=group)

##filtering- change cds value to customize
keep <- rowSums(cpm(cds)>1) >= min(num_of_ctrl,num_of_case) 
cds <- cds[keep, ,keep.lib.sizes=FALSE]

##calculate normalization factors
cds <- calcNormFactors( cds )
grp_color<- c (rep("red",num_of_ctrl),rep("blue",num_of_case))
##estimate dispersions
cds <- estimateCommonDisp( cds )
cds <- estimateTagwiseDisp( cds)

##variance plot
png(file="Mean_Variance_plot.png")
meanVarPlot <- plotMeanVar( cds , show.raw.vars=TRUE ,show.tagwise.vars=TRUE ,show.binned.common.disp.vars=FALSE ,show.ave.raw.vars=FALSE ,dispersion.method = "qcml" , NBline = TRUE ,nbins = 100 ,pch = 16 ,xlab="Mean Expression (Log10 Scale)" ,ylab = "Variance (Log10 Scale)" ,main ="Mean-Variance Plot" )
dev.off()

##testing for DE genes
de.cmn <- exactTest( cds, pair = c( control , case ), dispersion="common" ) 
de.tgw <- exactTest( cds, pair = c( control, case ),dispersion="tagwise" )
de.poi <- exactTest( cds , dispersion = 1e-06 , pair = c( control , case ) )
##return n results
resultsByFC.tgw <- topTags( de.tgw , n = nrow( de.tgw$table ) , sort.by ="logFC" )$table

resultsTbl.cmn <- topTags( de.cmn , n = nrow( de.cmn$table ) )$table
resultsTbl.tgw <- topTags( de.tgw , n = nrow( de.tgw$table ) )$table
resultsTbl.poi <- topTags( de.poi , n = nrow( de.poi$table ) )$table

de.genes.cmn <- rownames( resultsTbl.cmn )[ resultsTbl.cmn$PValue <= 0.05 ]
de.genes.tgw <- rownames( resultsTbl.tgw )[ resultsTbl.tgw$PValue <= 0.05 ]
de.genes.poi <- rownames( resultsTbl.poi )[ resultsTbl.poi$PValue <= 0.05 ]

sum( de.genes.tgw[1:1000] %in% de.genes.cmn[1:1000] ) / 1000 * 100
# Percent shared out of top 10, 100 & 1000 between tagwise and poisson
sum( de.genes.tgw[1:10] %in% de.genes.poi[1:10] ) / 10 * 100
sum( de.genes.tgw[1:100] %in% de.genes.poi[1:100] )
sum( de.genes.tgw[1:1000] %in% de.genes.poi[1:1000] ) / 1000 * 100

# visualize expression levels for top DE genes
png(file="Differential_expression_all_genes_plot.png")
par( mfrow=c(3 ,1) )
hist( resultsTbl.poi[de.genes.poi[1:100],"logCPM"] , breaks=100 , xlab="Log Concentration" , col="red" , freq=FALSE , main="Poisson: Top 100" )
hist( resultsTbl.cmn[de.genes.cmn[1:100],"logCPM"] , breaks=100 , xlab="Log Concentration" ,col="green" , freq=FALSE , main="Common: Top 100" )
hist( resultsTbl.tgw[de.genes.tgw[1:100],"logCPM"] , breaks=100 , xlab="Log Concentration" , col="blue" , freq=FALSE , main="Tagwise: Top 100" )
dev.off()

## MA plot, but on top 500 DE genes
png(file="MA_plot_top_500_genes.png")
#par( mfrow = c(2,1) )
#plotSmear( cds , de.tags=de.genes.poi[1:500] , main="Poisson" ,pair=c(control,case),cex=.5 ,xlab="Log Concentration" , ylab="Log Fold-Change" )
#abline( h = c(-2, 2) , col = "dodgerblue" )
plotSmear( cds , de.tags=de.genes.tgw[1:500] , main="MA Plot" ,pair=c(control,case),cex = .5 ,xlab="Log Concentration" , ylab="Log Fold-Change" )
abline( h = c(-2, 2) , col = "dodgerblue" )
#par( mfrow=c(1,1) )
dev.off()

## outputting results
# re-order count matrix to be in line with the order of results
wh.rows.tgw <- match( rownames( resultsTbl.tgw ) , rownames( cds$counts ) )
wh.rows.cmn <- match( rownames( resultsTbl.cmn ) , rownames( cds$counts ) )
head( wh.rows.tgw )
# tagwise results
combResults.tgw <- cbind( resultsTbl.tgw ,"Tgw.Disp" = cds$tagwise.dispersion[
wh.rows.tgw ] ,"UpDown.Tgw" = decideTestsDGE( de.tgw , p.value = 0.05 )[
wh.rows.tgw ] ,cds$counts[ wh.rows.tgw , ] )
combResults.cmn <- cbind( resultsTbl.cmn ,"Cmn.Disp" = cds$common.dispersion
,"UpDown.Cmn" = decideTestsDGE( de.cmn , p.value = 0.05 )[ wh.rows.cmn ]
,cds$counts[ wh.rows.cmn , ] )
# combining common and tagwise results
wh.rows <- match( rownames( combResults.cmn ) , rownames( combResults.tgw ) )
combResults.all <- cbind( combResults.cmn[,1:4] ,combResults.tgw[wh.rows,3:4], "Cmn.Disp" = combResults.cmn[,5],"Tgw.Disp" =combResults.tgw[wh.rows,5],"UpDown.Cmn" = combResults.cmn[,6],"UpDown.Tgw" =combResults.tgw[wh.rows,6],combResults.cmn[,7:ncol(combResults.cmn)] )
head( combResults.all )

# Ouput csv tables of results
write.table( combResults.tgw , file ="tgw_control.vs.case.csv" , sep = "," , row.names =TRUE )
write.table( combResults.cmn , file ="cmn_control.vs.case.csv" , sep = "," , row.names =TRUE )
write.table( combResults.all , file ="all_control.vs.case.csv" , sep = "," , row.names = TRUE)
