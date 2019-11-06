#!/bin/bash

    if [ $# != 2 ]; then
	echo "USAGE: run.sh <config_dir> <output_dir>"
	exit 1;
    else
	configs=$1
	outdir=$2
	# mySamps is a space seperated list of indexes
	mySamps="burkitt_s5 burkitt_s6 cd10_s10 cd10_s9"
	module load Java/1.8.0_181

	cd ${outdir}
    	for samp in ${mySamps}; do
        	echo "Running sample ${samp}"
		mkdir ${samp}
        	cd ${samp}
        	time bash /fh/fast/_SR/Genomics/proj/kloeb/190501_DuplexSequencing/Kohrn_DCS_pipeline.0.2.0.edit.sh ${configs}/${samp}_config.sh
        	cd ..
    	done

fi 
