#!/bin/bash
##run cellranger aggregate on multiple libraries

if [ $# != 3 ]; then
	echo "USAGE: bash CR_aggr.sh ID sample_csv outdir"
	exit 1
else
	echo `date`
	
	id=$1
	csv=$2
	outdir=$3
	
	module load cellranger/3.0.2
	cd $outdir
		
	/usr/bin/sbatch --workdir=${outdir} -J aggr_${id} --mem=25G --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org -o ${outdir}/%x.%j.out --wrap="cellranger aggr --id=${id} --csv=${csv}"

fi
