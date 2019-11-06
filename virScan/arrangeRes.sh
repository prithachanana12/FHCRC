#!/bin/bash

cd /shared/ngs/illumina/tsayers/190603_D00300_0752_BHYVTWBCX2/results
dirNames="bam
          count
          log
          zihit
          zipval
          ziscore"
for d in $dirNames; do mkdir $d; done
mv *.bam* bam &
mv *.count.csv.gz count &
mv *.log log &
mv *.zihit.csv.gz zihit &
mv *.zipval.csv.gz zipval &
mv *.ziscore.spp.csv.gz ziscore &
