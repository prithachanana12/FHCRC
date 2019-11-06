#!/bin/bash

if [ $# != 5 ]; then
	echo "USAGE: bash featureCounts.sh <s1:s2:..:sn> <input_dir> <output_dir> <GTF file> <strand>"
	echo "Input directory is the location with per-sample alignment results."
	echo "Output directory is the location where the results will go."
	echo "Strand is 0 for unstranded, 1 for stranded and 2 for reversely stranded."
	exit 1;
else
	samples=$1
	indir=$2
	outdir=$3
	gtf=$4
	strand=$5
	fC=/home/solexa/apps/subread/subread-1.6.0-Linux-x86_64/bin/featureCounts

	for s in $(echo $samples | tr ':' ' '); do 
		mkdir -p ${outdir}/${s}
		bam=${indir}/${s}/two_pass/Aligned.sortedByCoord.out.bam
		/usr/bin/sbatch --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org --output=${outdir}/${s}/%x.%j.out -J fC_${s} --mem=15G --wrap="$fC -a $gtf -p -s $strand -O -o ${outdir}/${s}/${s}.gene.count.tsv $bam"
	done 
fi
