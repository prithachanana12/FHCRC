#!/bin/bash
#SBATCH -N1 -n4 --mem=30G
#SBATCH --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org 
#SBATCH --output=/fh/scratch/delete30/_SR/Genomics/pchanana/%x.%j.out

module load STAR/2.7.1a-foss-2016b

##One-time process: creation of hg38 ref
##comment out after first time ref generation
time STAR --runThreadN 4 --runMode genomeGenerate --genomeDir /fh/fast/_SR/Genomics/user/pchanana/references/rn6 --genomeFastaFiles /fh/fast/_SR/Genomics/user/pchanana/references/rn6/Rattus_norvegicus.Rnor_6.0.dna.toplevel.fa --sjdbGTFfile /fh/fast/_SR/Genomics/user/pchanana/references/rn6/Rattus_norvegicus.Rnor_6.0.97.gtf --sjdbOverhang 100
