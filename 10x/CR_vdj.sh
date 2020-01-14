#!/bin/bash
##Run cellranger vdj on given sample(s) for hg38.

if [ $# != 3 ]; then
	echo "USAGE: bash CR_vdj.sh <sample_id> <path to fastqs> <out dir>."
	echo "sample_id: as specified in the samplesheet.csv used for mkfastq."
	exit 1;
else
	echo `date`
	sample=$1
	fq=$2
	outdir=$3
	ref=/fh/fast/_SR/Genomics/data/cellranger/refdata-cellranger-vdj-GRCh38-alts-ensembl-2.0.0

	ml cellranger/3.0.2
	cd $outdir
	
	/usr/bin/sbatch -J vdj_${sample} --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org --workdir=${outdir} -o /fh/scratch/delete30/_SR/Genomics/pchanana/%x.%j.out --mem=20G --ntasks-per-node=1 --wrap="cellranger vdj --id=${sample}-vdj --fastqs=${fq} --reference=${ref} --sample=${sample}"

fi
