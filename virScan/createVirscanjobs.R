options(stringsAsFactors = F)
sampleSheet<-read.csv("/shared/ngs/illumina/solexa/SampleSheets/190814_SN367_1421_BH3G2JBCX3_tsayers.csv")
names(sampleSheet)[3]<-"SampleName"
flowCell <- "190814_SN367_1421_BH3G2JBCX3"

sampleSheet<-data.frame(SampleName = sampleSheet$SampleName,
                        Lane = sampleSheet$Lane)
sampleSheet$SampleName<-sub("_rep[1-2]$","",sampleSheet$SampleName)
sampleSheet <- unique(sampleSheet); nrow(sampleSheet) #173
sampleSheet <- sampleSheet[grep("library_", sampleSheet$SampleName, invert = T),]; nrow(sampleSheet)

sbatchPath <- "/fh/fast/_SR/Genomics/user/pchanana/2019.06.04.tsayers/qsub_files/VirScan/"
resultsDir <- "/fh/fast/_SR/Genomics/user/pchanana/2019.06.04.tsayers/results"
system(paste0("cp /shared/ngs/illumina/tsayers/180518_SN367_1176_AHGMG3BCX2/results/count/Library_Jan2018.count.csv.gz ",resultsDir))

sampleDir = paste0("/shared/ngs/illumina/tsayers/", flowCell, "/filtered")

for(i in 1:nrow(sampleSheet)){
  if(grepl("SABES", sampleSheet$SampleName[i]) == TRUE){
    InputCounts <- "Library_Jan2018.count.csv.gz"
  }
  if(grepl("IDS065p1", sampleSheet$SampleName[i]) == FALSE){
    InputCounts <- "library_July_2019.count.csv.gz"
  }
  cat("#!/bin/bash
      #SBATCH -N1 -n1 -t 0-2
      module load bowtie/1.1.1
      PATH=/home/solexa/apps/samtools/samtools-1.3.1:/home/solexa/apps/anaconda3/bin:$PATH
      bowtieIndex=/shared/solexa/solexa/Genomes/genomes/PhIPseq/vir2/vir2
      scriptsPATH=/home/solexa/scripts/PhIPseq
      refDir=/shared/ngs/illumina/rbasom/2016.10.14.rbender
      refFilesDir=$refDir/VirScanPipelineTransfer", file=paste(sbatchPath, sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n")
      cat(paste0("inputCounts=", resultsDir, "/", InputCounts), file=paste(sbatchPath, sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n", append = TRUE)
      cat("threshold=2.3
      metaData=$refDir/SABES/VIR2.csv.gz
      groupingLevel=Species
      epitopeLength=7
      nhitsBeads=$refFilesDir/vir2.nhits.beads.csv.gz
      nhitsSamples=$refFilesDir/vir2.nhits.samps.csv.gz",
      file=paste(sbatchPath, sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n", append = TRUE)
  cat(paste0("sampleName=", sampleSheet$SampleName[i]), file=paste(sbatchPath, sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n", append=TRUE) 
  cat(paste0("resultsDir=", resultsDir), file=paste(sbatchPath, sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n", append=TRUE) 
  cat(paste0("cd ", sampleDir), 
      file=paste(sbatchPath, sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n", append=TRUE)
  # rep1<-dir(sampleDir, pattern=Rep1$Sample[i])
  # rep2<-dir(sampleDir, pattern=Rep2$Sample[i])
  rep1<-paste0(sampleSheet$SampleName[i],"_rep1")
  rep2<-paste0(sampleSheet$SampleName[i],"_rep2")
  cat(paste0("rep1=", rep1), 
      file=paste(sbatchPath, sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n", append=TRUE)
  cat(paste0("rep2=", rep2), 
      file=paste(sbatchPath, sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n", append=TRUE)
  
  cat("zcat $rep1.R1.fastq.gz | bowtie -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet $bowtieIndex - | samtools view -u - | samtools sort - > $resultsDir/$sampleName.rep1.bam
zcat $rep2.R1.fastq.gz | bowtie -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet $bowtieIndex - | samtools view -u - | samtools sort - > $resultsDir/$sampleName.rep2.bam
cd $resultsDir
samtools index $sampleName.rep1.bam
samtools index $sampleName.rep2.bam
samtools idxstats $sampleName.rep1.bam | cut -f 1,3 | sed -e \'/^\\*\\t/d\' -e \"1 i id\\t$sampleName\" | tr \"\\\\t\" \",\" >$sampleName.rep1.count.csv
samtools idxstats $sampleName.rep2.bam | cut -f 1,3 | sed -e \'/^\\*\\t/d\' -e \"1 i id\\t$sampleName\" | tr \"\\\\t\" \",\" >$sampleName.rep2.count.csv
gzip $sampleName.rep1.count.csv
gzip $sampleName.rep2.count.csv
mkdir -p $sampleName.log/rep1
mkdir -p $sampleName.log/rep2
python /home/solexa/scripts/PhIPseq/calc_zipval.py $sampleName.rep1.count.csv.gz $inputCounts $sampleName.log/rep1 > $sampleName.rep1.zipval.csv
python /home/solexa/scripts/PhIPseq/calc_zipval.py $sampleName.rep2.count.csv.gz $inputCounts $sampleName.log/rep2 > $sampleName.rep2.zipval.csv
gzip $sampleName.rep1.zipval.csv
gzip $sampleName.rep2.zipval.csv
python /home/solexa/scripts/PhIPseq/call_hits.py $sampleName.rep1.zipval.csv.gz $sampleName.rep2.zipval.csv.gz $sampleName.log $threshold  > $sampleName.zihit.csv
gzip $sampleName.zihit.csv
#Caclulate virus scores from hits
python $scriptsPATH/calc_scores.py $sampleName.zihit.csv.gz $metaData $nhitsBeads $nhitsSamples $groupingLevel $epitopeLength > $sampleName.ziscore.spp.csv
gzip $sampleName.ziscore.spp.csv",
      file=paste(sbatchPath, sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n", append=TRUE)
}

