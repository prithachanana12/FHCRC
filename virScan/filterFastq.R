options(stringsAsFactors = F)
sampleSheet<-read.csv("~/Desktop/ngs/solexa/SampleSheets/190814_SN367_1421_BH3G2JBCX3_tsayers.csv")
names(sampleSheet)[3]<-"SampleName"
flowCell <- "190814_SN367_1421_BH3G2JBCX3"

#filter fastq files and write results to single directory
for(i in 1:nrow(sampleSheet)){
  cat("#!/bin/bash
#SBATCH -N1 -n1 -t 0-1", file=paste(sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n")
cat(paste0("sampleName=", sampleSheet$SampleName[i]), file=paste(sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n", append = T)
cat(paste0("transferDirectory=/shared/ngs/illumina/tsayers/", flowCell), file=paste(sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n", append = T)
cat("sampleDir=$transferDirectory/Unaligned/Project_tsayers/Sample_$sampleName
filteredDir=$transferDirectory/filtered
cd $sampleDir
for i in *_R1_*fastq.gz
do
zgrep -A 3 \'^@.*[^:]*:N:[^:]*:\' $i | zgrep -v \'^\\-\\-$\' >> $filteredDir/$sampleName.R1.fastq
done
gzip $filteredDir/$sampleName.R1.fastq
ml FastQC/0.11.8-Java-1.8
cd $filteredDir
fastqc $sampleName.R1.fastq.gz -o ../fastqc
exit 0",file=paste(sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n", append = T)
}

fastqFilterDir <- "~/Desktop/ngs/ngs/illumina/tsayers/190814_SN367_1421_BH3G2JBCX3/qsub_files/filter"
system(paste0("mkdir ", fastqFilterDir))
system(paste0("mv *.sbatch ", fastqFilterDir))
system(paste0("mkdir ~/Desktop/ngs/ngs/illumina/tsayers/", flowCell, "/filtered"))
system(paste0("mkdir ~/Desktop/ngs/ngs/illumina/tsayers/", flowCell, "/fastqc"))

##submit the batch jobs from rhino
