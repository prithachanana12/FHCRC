#!/bin/bash
##run cellranger count

if [ $# != 4 ]; then
	echo "USAGE: sh cellranger.sh working_dir sample_name fastq_dir ref_dir"
	exit 1
else
	echo `date`
	
	work_dir=$1
	sample=$2
	in_dir=$3
	refs=$4
	
	module load cellranger/3.0.2
	cd $work_dir
	
	/usr/bin/sbatch --workdir=${work_dir} -J count_${sample} --mem=25G --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org -o ${work_dir}/%x.%j.out --wrap="cellranger count --id=${sample} --sample=${sample} --fastqs=${in_dir} --transcriptome=${refs}"

fi
