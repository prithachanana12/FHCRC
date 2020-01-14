#!/bin/bash

if [ $# != 1 ]; then
	echo "USAGE: bash getAlignStats.sh outs_dir"
	echo "Input dir is the location where all bowtie sbatch and out files are present"
	exit 1;
else
	outs=$1
	
	cd $outs
	touch alignStats.txt
	for i in $(ls *.out); do
		echo -e $(ls $i | cut -f1 -d".")"\t"$(head -1 $i | cut -f2 -d":" | sed 's/ //g')"\t"$(head -2 ${i} | tail -1 | cut -f2 -d":" | sed 's/ //g' | cut -f1 -d"(")"\t"$(head -2 ${i} | tail -1 | cut -f2 -d":" | sed 's/ //g' | cut -f2 -d"(" | sed 's/)//')"\t"$(head -3 ${i} | tail -1 | cut -f2 -d":" | sed 's/ //g' | cut -f1 -d"(")"\t"$(head -3 ${i} | tail -1 | cut -f2 -d":" | sed 's/ //g' | cut -f2 -d"(" | sed 's/)//') >> alignStats.txt
	done
fi
