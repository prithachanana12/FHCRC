#!/bin/bash
##run cellranger mkfastq

if [ $# != 2 ]; then
	echo "USAGE: bash CR_mkfastq.sh illumina_BCL_dir samplesheet_csv"
	exit 1
else
	echo `date`
	
	bcl=$1
	csv=$2
	
	module load cellranger/3.0.2
	cd $bcl
		
	/usr/bin/sbatch --workdir=${bcl} -J mkfastq --mem=25G --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org --ntasks-per-node=1 --wrap="cellranger mkfastq --run=${bcl} --csv=${csv} --qc" 

fi
