#!/bin/bash

samples="Sample_ITD8-1 Sample_ITD8-2 Sample_ITD8-3 Sample_VecB3-1 Sample_VecB3-2 Sample_VecB3-3 Sample_WTA4-1 Sample_WTA4-2 Sample_WTA4-3"
indir="/shared/ngs/illumina/pcheng/190822_SN367_1423_AH3MYJBCX3/Unaligned/Project_pcheng"
outdir="/fh/fast/_SR/Genomics/user/pchanana/pcheng_bulkRNA_Aug2019/fastq/rat/190822_SN367_1423_AH3MYJBCX3"

for i in $samples; do
	samp=$(echo $i | sed 's/Sample_//')
	cd $indir
	cat ${i}/${samp}_[ATGC]*_L001_R1* > ${outdir}/${samp}_L001_R1.fastq.gz
	cat ${i}/${samp}_[ATGC]*_L001_R2* > ${outdir}/${samp}_L001_R2.fastq.gz
	#cat ${i}/${samp}_[ATGC]*_L002_R1* > ${outdir}/${samp}_L002_R1.fastq.gz
	#cat ${i}/${samp}_[ATGC]*_L002_R2* > ${outdir}/${samp}_L002_R2.fastq.gz
done 
