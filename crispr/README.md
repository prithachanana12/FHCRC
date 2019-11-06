#CRISPR pipeline steps
##Location for refs: /fh/fast/_SR/Genomics/user/pchanana/references/CRISPR

1. Edit the R script below with correct paths, and run the script to create alignment sbatch files in the working directory.
   Check the length of the fastq reads - usual trimming is 30 bases from 5' end and as-needed from 3' end to get 20bp reads to be aligned.  
	Rscript /fh/fast/_SR/Genomics/user/pchanana/scripts/crispr/generateScreenBatchJobs.R 
2. Once the bt files are generated, run the following two scripts to generate the alignment stats and counts files:
	1. /home/solexa/scripts/crisprAlignmentStats from the directory where all .out files from step 1 are located
	2. /home/solexa/scripts/crisprCounts from the directory with the per-sample .bt files
3. Preprocess and merge the count files. Appropriately move individual files to sub-directories depending on the sample groups to be combined.
	Rscript /fh/fast/_SR/Genomics/user/pchanana/scripts/crispr/mergeCounts.R 
4. QC plots: PCA, boxplots and correlation matrices.
	Rscript /fh/fast/_SR/Genomics/user/pchanana/scripts/crispr/crisprQC.R 
5. Differential expression using edgeR. Input file will be merged counts file from step 3. Minor pre-processing of counts files might be needed depending on the samples to be used in the comparison (cut out columns or rearrange using awk).
	Rscript /fh/fast/_SR/Genomics/user/pchanana/scripts/crispr/edgeR.R 
6. Join with annotation files to add gene name and other annotations to the guide sequences. If one guide sequence has multiple gene annotations, following line of R code can be used to collapse the multiple gene annotations in a single comma-separated column.
	In the following example, 'sgRNA' is the guide sequence and one sgRNA has multiple 'GeneName' cols associated with it. 
	`{r codeblock1}
	tab2 <- tab %>% group_by(sgRNA) %>% mutate(Genes=paste(GeneSymbol,collapse=", ")) %>% select(-GeneSymbol) %>% distinct()
	`
	script for above: /fh/fast/_SR/Genomics/user/pchanana/scripts/crispr/DE_postProcess.R
7. Create QC plots.
	Rscript /fh/fast/_SR/Genomics/user/pchanana/scripts/crispr/volcano.R 
