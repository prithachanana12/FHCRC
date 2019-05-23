#!/bin/bash

if [ $# != 2 ]
then
	echo "Run xenome single-end for 10x data"
	echo "Usage: bash xenome.sh <path to R2 fastq> <output dir>";
	echo "Xenome successfully runs only on unzipped fastqs"
else
	set -x
	echo `date`	
	R2=$1
	out_dir=$2
	
	index=/fh/fast/_SR/Genomics/user/pchanana/references/xenome_hg38-mm10
	HumanReference=/fh/fast/_SR/Genomics/biodata/ngs/Reference/10X/refdata-cellranger-GRCh38-3.0.0/fasta/genome.fa
	MouseReference=/fh/fast/_SR/Genomics/biodata/ngs/Reference/10X/refdata-cellranger-mm10-3.0.0/fasta/genome.fa
	xenome=/fh/fast/_SR/Genomics/user/pchanana/software/gossamer/usr/local/bin/xenome
	sample=$(basename $R2 .fastq)
	mkdir -p $out_dir/$sample
	output=$out_dir/$sample
	mkdir -p $output/tmp
#	mkdir -p $index/tmp
#	mkdir -p $index/logs
	
	# To generate the indexes using the human and mouse reference genomes. This is a one time job. Once the indexes are created, the xenome classify command can be run on all the samples.
#	/usr/bin/sbatch --workdir=${index}/logs -J xenome_index --mem=24G --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org --cpus-per-task=4 --ntasks-per-node=1 --wrap="$xenome index -P $index/index -H $MouseReference -G $HumanReference --tmp-dir $index/tmp"
	cd $output
	/usr/bin/sbatch --workdir=${output} -J classify_${sample} --mem=20g --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org --ntasks-per-node=1 --wrap="$xenome classify -M 18 -P $index/index -i $input/$R2 --tmp-dir $output/tmp --graft-name human --host-name mouse --output-filename-prefix $sample"

fi
