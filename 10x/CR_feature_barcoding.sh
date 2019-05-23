#!/bin/bash
##analyze GEX libraries with antibody capture ones for feature barcoding/hashing. 

if [ $# != 4 ]; then
	echo "USAGE: bash CR_feature_barcoding.sh <libraries csv> <feature reference csv> <output dir> <out folder name>"
	echo "Cellranger will create a dir called 'out folder name' under output dir."
	exit 1;
else
	echo `date`
	lib=$1
	features=$2
	out_dir=$3
	res=$4
	ref=/fh/fast/_SR/Genomics/biodata/ngs/Reference/10X/refdata-cellranger-GRCh38-3.0.0/

	ml cellranger/3.0.2
	cd $out_dir

	/usr/bin/sbatch -J FB_${res} --mem=30G --mail-type=END,FAIL --mail-user=pchanana@fhcrc.org --workdir=${out_dir} --ntasks-per-node=1 --wrap="cellranger count --id=${res} --libraries=${lib} --feature-ref=${features} --transcriptome=${ref}"

fi	
