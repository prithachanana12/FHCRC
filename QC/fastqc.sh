#!/bin/bash

if [ $# != 2 ]; then
	echo "USAGE: bash fastqc.sh sample_name input_dir"
	exit 1;
else
	echo `date`

	s=$1
	dir=$2
	r1=${dir}/${s}_R1.fq.gz
	r2=${dir}/${s}_R2.fq.gz
	logs=${dir}/logs
	mkdir -p $logs

	/usr/bin/sbatch -J fastqc_r1_${s} --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org --mem=5G -o ${logs}/%x.%j.out --wrap="/usr/bin/fastqc -o ${dir} -f fastq ${r1}"
	/usr/bin/sbatch -J fastqc_r2_${s} --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org --mem=5G -o ${logs}/%x.%j.out --wrap="/usr/bin/fastqc -o ${dir} -f fastq ${r2}"

fi
