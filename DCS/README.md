#DCS Analysis Steps:
##Path to pipeline - /fh/fast/_SR/Genomics/proj/kloeb/190501_DuplexSequencing/DCSv3.0_python3_dist

1. Create targets bed file - sort, merge bed file to remove duplicate coordinates.
2. Create interval list with instructions in the file - DuplexSequencingInstructions.txt.
	involves concatenation of the reference dict file and targets bed. 
3. Create the pre-config file using instructions from file mentioned in step 2. 
4. Run makeConfigs.py to create config files per sample.
5. Edit the config file with the appropriate values for tagLen, spacerLen and locLen according to the chemistry of the raw data.
	In the first (traditional DS), the parameters are: tagLen=12; spacerLen=5; locLen=0.
	The second is a transitional pipeline that was only used by a few labs, which has parameters: tagLen=10; spacerLen=1; locLen=0.
	The third method is used with the Twinstrand kit, and is specialized for deterministic barcode sequences; this is the whole reason the locLen parameter exists.  It has parameters: tagLen=8; spacerLen=1; locLen=10.
	This bash script will make the required edits: /fh/fast/_SR/Genomics/user/pchanana/scripts/DCS/configParams.sh
6. Create a new tmux session (the pipeline takes a while, and the time can blow up depending on the number of samples. If running interactively, the samples can only be run sequentially otherwise the java machine runs out of memory), and use grabnode to start an interactive session on one of the gizmos. Activate the 'dcs' conda environment to load the appropriate environment variables. Run the samples interactively as shown below: 
	nohup bash /fh/fast/_SR/Genomics/user/pchanana/scripts/DCS/DCS_run.sh <path to config files> <path to output directory> > log.txt 2>&1
7. Once the runs are finished, move the sample config files to their respective results folders before generating cummulative summary files. 
8. Run the retrieveSummary2.py script. Input file will be a list of sample/results dir names - one per line. 
	python /fh/fast/_SR/Genomics/proj/kloeb/190501_DuplexSequencing/DCSv3.0_python3_dist/retrieveSummary2.py --indexes index.txt
9. Filter sscs mutpos files to remove positions with single variants on them.
	/fh/fast/_SR/Genomics/user/pchanana/scripts/DCS/filter_sscs.sh
10. position mutation fraction plots
