args =  commandArgs(TRUE)
ss=args[1]
sampleDir=args[2]
outDir=args[3]
if (file.exists(ss) == FALSE || length(args) != 3){
  writeLines ("Usage:\nRscript filterFastq.R <path to sample sheet> <path to NGS directory upto flowcell name where samples are located> <output dir>\n");
  quit()
}

options(stringsAsFactors = F)
sampleSheet<-read.csv(ss)
names(sampleSheet)[3]<-"SampleName"
user <- "kloeb"
#flowCell <- "190814_SN367_1421_BH3G2JBCX3"

#filter fastq files and write results to single directory
for(i in 1:nrow(sampleSheet)){
  cat("#!/bin/bash", file=paste(sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n")
  cat("#SBATCH -N1 -n1 -t 0-1 --mail-type=END --mail-user=pchanana@fhcrc.org", file=paste(sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n",append=TRUE)
  cat(paste0("sampleName=", sampleSheet$SampleName[i]), file=paste(sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n", append = T)
  cat(paste0("transferDirectory=", sampleDir), file=paste(sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n", append = T)
  cat(paste0("user=", user), file=paste(sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n", append = T)
  cat(paste0("outDir=", outDir), file=paste(sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n", append = T)
  cat("sampleDir=$transferDirectory/Unaligned/Project_$user/Sample_$sampleName
filteredDir=$outDir/filtered
mkdir -p $filteredDir
cd $sampleDir
for i in *_R1_*fastq.gz
do
zgrep -A 3 \'^@.*[^:]*:N:[^:]*:\' $i | zgrep -v \'^\\-\\-$\' >> $filteredDir/$sampleName.R1.fastq
done
for i in *_R2_*fastq.gz
do
zgrep -A 3 \'^@.*[^:]*:N:[^:]*:\' $i | zgrep -v \'^\\-\\-$\' >> $filteredDir/$sampleName.R2.fastq
done
gzip $filteredDir/$sampleName.R1.fastq
gzip $filteredDir/$sampleName.R2.fastq
ml FastQC/0.11.8-Java-1.8
cd $filteredDir
mkdir $filteredDir/fastqc
fastqc $sampleName.R1.fastq.gz -o $filteredDir/fastqc
fastqc $sampleName.R2.fastq.gz -o $filteredDir/fastqc
exit 0",file=paste(sampleSheet$SampleName[i],".sbatch",sep=""),sep="\n", append = T)
}

#fastqFilterDir <- "~/Desktop/ngs/ngs/illumina/tsayers/190814_SN367_1421_BH3G2JBCX3/qsub_files/filter"
#system(paste0("mkdir ", fastqFilterDir))
#system(paste0("mv *.sbatch ", fastqFilterDir))
#system(paste0("mkdir ~/Desktop/ngs/ngs/illumina/tsayers/", flowCell, "/filtered"))
#system(paste0("mkdir ~/Desktop/ngs/ngs/illumina/tsayers/", flowCell, "/fastqc"))

##submit the batch jobs from rhino
