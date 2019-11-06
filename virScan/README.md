#virScan pipeline steps

1. Sample sheet will be located at /shared/ngs/illumina/solexa/SampleSheets/.
2. Create the batch job scripts for filtering raw FASTQs and running FASTQC. Submit all sbatch files to cluster.
	Rscript /fh/fast/_SR/Genomics/user/pchanana/scripts/virScan/filterFastq.R
3. Generate alignment and counts for the library (if needed, older libraries can be re-used if already created).
	bash /fh/fast/_SR/Genomics/user/pchanana/scripts/virScan/generateLib.sh
4. Create the batch job scripts for the virscan pipeline to run. Submit all sbatch files to cluster. 
	Rscript /fh/fast/_SR/Genomics/user/pchanana/scripts/virScan/createVirscanjobs.R
5. Re-arrange the results directory:
	bash /fh/fast/_SR/Genomics/user/pchanana/scripts/virScan/arrangeRes.sh
6. Get demux stats file, and put it in the summary directory. The html file for demux stats is present in the shared directory with the raw data. Open it in a browser and copy the table as tab-delimited. 
	/shared/ngs/illumina/tsayers/190814_SN367_1421_BH3G2JBCX3/Unaligned/Basecall_Stats_H3G2JBCX3/Demultiplex_Stats.htm
7. Generate summaries of results:
	Rscripts /fh/fast/_SR/Genomics/user/pchanana/scripts/virScan/generateSummary.R 
