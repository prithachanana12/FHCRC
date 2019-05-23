#!/home/pchanana/miniconda3/bin/python

import argparse
import gzip

def main(barcodes,list_bc,outfile):
	f=open(outfile,'w')
	with gzip.open(barcodes,'r') as f1:
		bc1=[line.rstrip().decode("utf-8") for line in f1.readlines()]
		#print(bc1[0:5])
	with open(list_bc,'r') as f2:
		bc2=[l.rstrip() for l in f2.readlines()]
		#print(bc2[0:5])
	for elem in bc2:
		if elem in bc1:
			f.write(elem+'\n')
	f.close()

if __name__ == "__main__":
	parser=argparse.ArgumentParser(description="checks user-input list of BCs against Cellranger count's filtered BC matrix to remove error source while running cellranger reanalyze")
	parser.add_argument("-b",metavar="barcodes.tsv.gz file from filtered_feature_bc_matrix")
	parser.add_argument("-csv",metavar="list of barcodes to include in reanalysis")
	parser.add_argument("-o",metavar="path to output file")
	args=parser.parse_args()
	bc3 = main(args.b,args.csv,args.o)
