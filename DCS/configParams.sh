#!/bin/bash

if [ $# != 2 ]; then
	echo "USAGE: bash configParams.sh <input file> <kit>"
	echo "kits: traditional,transitional,twinstrand"
	exit 1;
else
	infile=$1
	kit=$2
	
	sed -i 's/runSSCS=False/runSSCS=TRUE/' ${infile}
	sed -i 's/runDCS=False/runDCS=TRUE/' ${infile}
	sed -i 's/makeDCS=False/makeDCS=TRUE/' ${infile}
	sed -i 's/cleanup=False/cleanup=FALSE/' ${infile}

	if [ "$kit" == "traditional" ]; then
		sed -i 's/locLen=10/locLen=0/' $infile
	elif [ "$kit" == "transitional" ]; then
		sed -i 's/tagLen=12/tagLen=10/' $infile
		sed -i 's/spacerLen=5/spacerLen=1/' $infile
		sed -i 's/locLen=10/locLen=0/' $infile
	elif [ "$kit" == "twinstrand" ]; then
		sed -i 's/tagLen=12/tagLen=8/' $infile
                sed -i 's/spacerLen=5/spacerLen=1/' $infile
	fi
fi
