#!/bin/bash

if [ $# != 2 ]; then
	echo "USAGE: bash filter_sscs.sh input_mutpos output_dir"
	exit 1;
else
	infile=$1
	outdir=$2
	outfile=$(basename ${infile}).filt.txt

	awk -F"\t" '$5>1 && ($6>1 || $7>1 || $8>1 || $9>1) {print}' ${infile} > ${outdir}/${outfile}

fi
