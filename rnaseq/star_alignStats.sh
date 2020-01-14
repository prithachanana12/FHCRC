#!/bin/bash

if [ $# != 2 ]; then
	echo "USAGE: bash star_alignStats.sh samples<colon-sep> <star_align dir>"
	exit 1;
else
	samps=$1
	indir=$2
	
	touch ${indir}/alignStats.txt
	echo -e "Sample\tTotalReads\tUniqueMap\tUniqueMap%\tMultiMap\tMultiMap%\tUnmap\tUnmap%" > ${indir}/alignStats.txt
	for s in $(echo $samps | tr ':' ' '); do
		logfile=${indir}/${s}/two_pass/Log.final.out
		total=$(cat $logfile | grep "Number of input reads" | cut -f2 -d"|" | sed 's/^\t//')
		uniqMap=$(cat $logfile | grep "Uniquely mapped reads number" | cut -f2 -d"|" | sed 's/^\t//')
		uniqPerc=$(cat $logfile | grep "Uniquely mapped reads %" | cut -f2 -d"|" | sed 's/^\t//' | sed 's/%$//')
		multiMap=$(expr $(cat $logfile | grep "Number of reads mapped to multiple loci" | cut -f2 -d"|" | sed 's/^\t//') + $(cat $logfile | grep "Number of reads mapped to too many loci" | cut -f2 -d"|" | sed 's/^\t//'))
		multiPerc=$(awk "BEGIN {print $(cat $logfile | grep '% of reads mapped to multiple loci' | cut -f2 -d'|' | sed 's/^\t//' | sed 's/%$//') + $(cat $logfile | grep '% of reads mapped to too many loci' | cut -f2 -d'|' | sed 's/^\t//' | sed 's/%$//')}")
		unmap=$(expr $(cat $logfile | grep 'Number of reads unmapped: too many mismatches' | cut -f2 -d'|' | sed 's/^\t//') + $(cat $logfile | grep 'Number of reads unmapped: too short' | cut -f2 -d'|' | sed 's/^\t//') + $(cat $logfile | grep 'Number of reads unmapped: other' | cut -f2 -d'|' | sed 's/^\t//'))
		unmapPerc=$(awk "BEGIN {print $(cat $logfile | grep '% of reads unmapped: too many mismatches' | cut -f2 -d'|' | sed 's/^\t//' | sed 's/%$//') + $(cat $logfile | grep '% of reads unmapped: too short' | cut -f2 -d'|' | sed 's/^\t//' | sed 's/%$//') + $(cat $logfile | grep '% of reads unmapped: other' | cut -f2 -d'|' | sed 's/^\t//' | sed 's/%$//')}")
		echo -e "$s\t$total\t$uniqMap\t$uniqPerc\t$multiMap\t$multiPerc\t$unmap\t$unmapPerc" >> ${indir}/alignStats.txt
	done
fi
