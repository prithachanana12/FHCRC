#!/bin/bash

if [ $# != 4 ]; then
	echo "This script runs the modules: geneBody coverage, Inner distance, Junction annotation and Read duplication on aligned BAM files"
	echo "USAGE: bash rseqc.sh <file with paths to BAMs, one sample per line> <refGene bed> <output dir> <subset chr for geneBodyCov>"
	exit 1;
else
	samples=$1
	rGbed=$2
	outdir=$3
	chr=$4
	rseqc="/fh/fast/_SR/Genomics/user/pchanana/software/RSeQC-3.0.0/bin"
	
	module load SAMtools/1.9-foss-2016b
	
	##geneBody coverage
	cd $outdir
	touch bams_chr${chr}.txt
	for s in $(cat $samples); do
		samp=$(echo $s | cut -f10 -d"/")
		samtools view -b $s $chr > ${samp}.chr${chr}.bam
		samtools index ${samp}.chr${chr}.bam
	done
	ls $outdir/*bam > bams_chr${chr}.txt
	/usr/bin/sbatch -J GBC --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org --output=/fh/scratch/delete30/_SR/Genomics/pchanana/%x.%j.out --mem=10G --wrap="python $rseqc/geneBody_coverage.py -i bams_chr${chr}.txt -r $rGbed -o geneBodycoverage"

	##inner distance, junction annotation and read duplication
	cd $outdir
	for s in $(cat $samples); do 
		prefix=$(echo $s | cut -f10 -d"/")
		/usr/bin/sbatch -J ${prefix}_ID --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org --output=/fh/scratch/delete30/_SR/Genomics/pchanana/%x.%j.out --mem=10G --wrap="python $rseqc/inner_distance.py -i ${s} -o ${prefix} -r ${rGbed}"
		/usr/bin/sbatch -J ${prefix}_JA --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org --output=/fh/scratch/delete30/_SR/Genomics/pchanana/%x.%j.out --mem=10G --wrap="python $rseqc/junction_annotation.py -i ${s} -o ${prefix} -r ${rGbed}"
		/usr/bin/sbatch -J ${prefix}_RD --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org --output=/fh/scratch/delete30/_SR/Genomics/pchanana/%x.%j.out --mem=10G --wrap="python $rseqc/read_duplication.py -i ${s} -o ${prefix}"
	done
fi
