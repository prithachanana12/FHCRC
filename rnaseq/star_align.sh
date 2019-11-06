#!/bin/bash

if [ $# != 4 ]; then
	echo "USAGE: bash star_align.sh <fastq_dir> <s1:s2:..:sn> <genome> <output_dir>"
	echo "genome is hg19, hg38, rn6 or mm10."
	echo "fastq_dir is colon separated list if multiple."
	exit 1;
else
	indir=$1
	samples=$2
	genome=$3
	outdir=$4
	#star=/app/easybuild/software/STAR/2.7.1a-foss-2016b/bin/STAR
	
	module load STAR/2.7.1a-foss-2016b

	##Update paths after new references are created
	if [ "$genome" == "mm10" ]; then
		STARref=/shared/biodata/ngs/Reference/iGenomes/Mus_musculus/UCSC/mm10/Sequence/STAR
		gtfFile=/shared/biodata/ngs/Reference/iGenomes/Mus_musculus/UCSC/mm10/Annotation/Archives/archive-2015-07-17-14-33-26/Genes/genes.gtf
	elif [ "$genome" == "hg19" ]; then
		STARref=/shared/biodata/ngs/Reference/iGenomes/Homo_sapiens/UCSC/hg19/Sequence/STAR
		gtfFile=/shared/biodata/ngs/Reference/iGenomes/Homo_sapiens/UCSC/hg19/Annotation/Archives/archive-2015-07-17-14-32-32/Genes/genes.gtf
	elif [ "$genome" == "hg38" ]; then
		STARref=/fh/fast/_SR/Genomics/user/pchanana/references/GRCh38/STARref
		gtfFile=/fh/fast/_SR/Genomics/user/pchanana/references/GRCh38/STARref/Homo_sapiens.GRCh38.93.gtf
	elif [ "$genome" == "rn6" ]; then
		STARref=/fh/fast/_SR/Genomics/user/pchanana/references/rn6/STARref
		gtfFile=/fh/fast/_SR/Genomics/user/pchanana/references/rn6/Rattus_norvegicus.Rnor_6.0.97.gtf
	fi
	
	##One-time process: creation of hg38 ref
	##comment out after first time ref generation
	#time STAR --runThreadN 4 --runMode genomeGenerate --genomeDir /fh/fast/_SR/Genomics/user/pchanana/references/GRCh38/STARref --genomeFastaFiles /fh/fast/_SR/Genomics/user/pchanana/references/GRCh38/STARref/Homo_sapiens.GRCh38.dna.primary_assembly.fa --sjdbGTFfile /fh/fast/_SR/Genomics/user/pchanana/references/GRCh38/STARref/Homo_sapiens.GRCh38.93.gtf --sjdbOverhang 100
	#STARref=/fh/fast/_SR/Genomics/user/pchanana/references/GRCh38/STARref
	#gtfFile=/fh/fast/_SR/Genomics/user/pchanana/references/GRCh38/STARref/Homo_sapiens.GRCh38.93.gtf	

	sj=""
	pass1_ids=""
	for sample in $(echo $samples | tr ':' ' '); do
		cd $outdir
		mkdir -p $sample
		cd $sample
		R1=""
		R2=""
		for dir in $(echo $indir | tr ':' ' '); do
			R1+=$(ls ${dir}/${sample}*R1.fastq.gz | tr '\n' ',')
			R2+=$(ls ${dir}/${sample}*R2.fastq.gz | tr '\n' ',')
		done
		R1=$(echo $R1 | sed 's/,$//')
		R2=$(echo $R2 | sed 's/,$//')
		job_id=$(/usr/bin/sbatch -p largenode -N1 -n6 --mem=55G --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org --output=/fh/scratch/delete30/_SR/Genomics/pchanana/%x.%j.out -J pass1_${sample} --wrap="STAR \
			--genomeDir $STARref \
			--readFilesIn ${R1} ${R2} \
			--readFilesCommand zcat \
			--runThreadN 4 \
			--sjdbGTFfile $gtfFile \
			--outFilterMultimapNmax 20 \
			--alignIntronMax 500000 \
			--alignMatesGapMax 1000000 \
			--sjdbScore 2 \
			--alignSJDBoverhangMin 1 \
			--outFilterMatchNminOverLread 0.33 \
			--outFilterScoreMinOverLread 0.33 \
			--sjdbOverhang 100 \
			--outSAMstrandField intronMotif \
			--outSAMtype None \
			--outSAMmode None")
		pass1_ids+="$(echo $job_id | cut -f4 -d" "),"
		sj+="$PWD/SJ.out.tab "
	done 
	#echo $sj
	ids=$(echo $pass1_ids | sed 's/,$//')
	for sample in $(echo $samples | tr ':' ' '); do
		cd $outdir
		mkdir -p ${sample}/two_pass
		cd ${sample}/two_pass
		R1=""
		R2=""
		for dir in $(echo $indir | tr ':' ' '); do
                        R1+=$(ls ${dir}/${sample}*R1.fastq.gz | tr '\n' ',')
                        R2+=$(ls ${dir}/${sample}*R2.fastq.gz | tr '\n' ',')
                done
		R1=$(echo $R1 | sed 's/,$//')
                R2=$(echo $R2 | sed 's/,$//')
		/usr/bin/sbatch -p largenode -N1 -n6 --mem=55G --mail-type=END,FAIL --mail-user=pchanana@fredhutch.org --output=/fh/scratch/delete30/_SR/Genomics/pchanana/%x.%j.out -J pass2_${sample} --dependency=afterok:${ids} --wrap="STAR \
			--genomeDir $STARref \
			--readFilesIn ${R1} ${R2} \
			--readFilesCommand zcat \
			--runThreadN 4 \
			--sjdbGTFfile $gtfFile \
			--outFilterMultimapNmax 20 \
			--alignIntronMax 500000 \
			--alignMatesGapMax 1000000 \
			--sjdbScore 2 \
			--alignSJDBoverhangMin 1 \
			--outFilterMatchNminOverLread 0.33 \
			--outFilterScoreMinOverLread 0.33 \
			--sjdbOverhang 100 \
			--outSAMstrandField intronMotif \
			--outSAMtype BAM SortedByCoordinate \
			--sjdbFileChrStartEnd $sj"
		done

fi
