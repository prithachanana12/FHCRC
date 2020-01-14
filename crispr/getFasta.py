#!/home/pchanana/miniconda3/bin/python

import argparse

def main(guides,outfile):
	f=open(outfile,'w')
	with open(guides,'r') as f1:
		for line in f1:
			guide=line.split("\t")[2].rstrip('\n')
			header=line.split("\t")[0].rstrip('\n')
			f.write(">"+header+"\n")
			f.write(guide+"\n")
	f.close()
	f1.close()

if __name__ == "__main__":
	parser=argparse.ArgumentParser(description="generates fasta file from tab-separated list of guides")
	parser.add_argument("-g",metavar="tab-sep guides list")
	parser.add_argument("-o",metavar="path to output file")
	args=parser.parse_args()
	main(args.g,args.o)
