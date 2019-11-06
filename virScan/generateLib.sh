#!/bin/bash

#generate counts from new input/library sample, this will only have to be done once and these input counts can be used for future experiments
#do this from the command line on rhino
module load bowtie/1.1.1
sampleName=library_July_2019
PATH=/home/solexa/apps/samtools/samtools-1.3.1:/home/solexa/apps/anaconda3/bin:$PATH
bowtieIndex=/shared/solexa/solexa/Genomes/genomes/PhIPseq/vir2/vir2
transferDir=/shared/ngs/illumina/tsayers/190814_SN367_1421_BH3G2JBCX3
resultsDir=$transferDir/results
mkdir $resultsDir
cd filtered
zcat $sampleName.R1.fastq.gz | bowtie -n 3 -l 30 -e 1000 --tryhard --nomaqround --norc --best --sam --quiet $bowtieIndex - | samtools view -u - | samtools sort - > $resultsDir/$sampleName.bam
cd $resultsDir
samtools index $sampleName.bam
samtools idxstats $sampleName.bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t$sampleName" | tr "\\t" "," >$sampleName.count.csv
gzip $sampleName.count.csv
