#!/bin/bash
##run cellranger count

if [ $# != 4 ]; then
	echo "USAGE: bash cr_atac_count.sh working_dir sample_name fastq_dir ref_dir"
	exit 1
else
	echo `date`
	
	work_dir=$1
	sample=$2
	in_dir=$3
	refs=$4
	
	module load cellranger-atac/1.1.0-foss-2016b
	source sourceme.bash
	cd $work_dir
	
	/usr/bin/sbatch --workdir=${work_dir} -J count_${sample} --mem=30G --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org -o /fh/scratch/delete30/_SR/Genomics/pchanana/%x.%j.out --wrap="cellranger-atac count --id=${sample} --sample=${sample} --fastqs=${in_dir} --reference=${refs}"

fi
