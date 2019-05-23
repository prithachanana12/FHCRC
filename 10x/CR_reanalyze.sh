#!/bin/bash
##run cellranger reanalyze

if [ $# != 4 ]; then
	echo "USAGE: bash CR_renalyze.sh working_dir sample_name filtered_feature_bc_matrix.h5 barcodes"
	exit 1
else
	echo `date`
	
	work_dir=$1
	sample=$2
	filt_h5=$3
	bcode=$4
	
	module load cellranger/3.0.2
	cd $work_dir
	id=${sample}_reanalysis
		
	/usr/bin/sbatch --workdir=${work_dir} -J re_${sample} --mem=25G --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org --cpus-per-task=4 --ntasks-per-node=1 --wrap="cellranger reanalyze --id=${id} --matrix=${filt_h5} --barcodes=${bcode}"

fi
