#!/usr/bin/env python

"""
Filter outputPrefix filter.bam target.bam [target_r1.fq [target_r2.fq]]

Given a set of reads aligned to two references, say one human and one mouse, retain those alignment
records or fastq sequences found with higher fidelity in the target than the filter alignment.
Fidelity here is measured strictly by the number of mismatches. For paired-end runs, mapping is
considered for the entire fragment. If a read is unmapped against either reference it is retained
in the ouput.
"""

import gzip
import sys
import os
import pysam

class AlignmentRecord(object):

    def __init__(self):
        self.readPaired = False
        self.filterPaired = False
        self.filterMismatch1 = 999
        self.filterMismatch2 = 999
        self.targetPaired = False
        self.targetMismatch1 = 999
        self.targetMismatch2 = 999

    def categorizeLoose(self):
        """if properly paired in filter and each end has two or fewer mismatches, call it filtered.
           if ends map to target and filter with fewer than two mismatches, flag as possible chimera
           otherwise retain as target

           t = target f = filter i = indeterminate c = chimera
           """

        if self.filterMismatch1 == self.targetMismatch1 and (not self.readPaired or self.filterMismatch2 == self.targetMismatch2):
            return 'i'

        # absolute mismatch count
        # TODO: consider mismatch qualities; requires MD
        if self.filterMismatch1 <= self.targetMismatch1 and (not self.readPaired or self.filterMismatch2 <= self.targetMismatch2):
            return 'f'

        # Using pairing status to disambiguate. Depends on alignment software; not always reliable
        if self.readPaired:
            if self.filterPaired and not self.targetPaired: return 'f'
            if self.targetPaired and not self.filterPaired: return 't'

            if self.filterMismatch1 == 999 and self.filterMismatch2 == 0 and self.targetMismatch2 == 999 and self.targetMismatch1 == 0:
                return 'c'
            if self.filterMismatch2 == 999 and self.filterMismatch1 == 0 and self.targetMismatch1 == 999 and self.targetMismatch2 == 0:
                return 'c'

        return 't'

    def categorizeStrict(self):
        """if read mapped in filter and target, regardless of number mismatches, call it indeterminate.

        if read is paired, and properly paired in filter and target, call it indeterminate.

        

if properly paired in filter and each end has two or fewer mismatches, call it filtered.
           if ends map to target and filter with fewer than two mismatches, flag as possible chimera
           otherwise retain as target

           t = target f = filter i = indeterminate c = chimera
           """

        if not self.readPaired:
            if self.filterMismatch1 < 999 and self.targetMismatch1 < 999: return 'i'
            if self.filterMismatch1 == 999: return 't'
            if self.targetMismatch2 == 999: return 'f'
        else:

            # Using pairing status to disambiguate. Depends on alignment software; not always reliable
            if self.filterPaired and not self.targetPaired: return 'f'
            if self.targetPaired and not self.filterPaired: return 't'

            if self.filterMismatch1 < 999 and self.targetMismatch1 < 999 and self.filterMismatch2 < 999 and self.targetMismatch2 < 999: return 'i'

            if self.filterMismatch1 < 999 and self.filterMismatch2 < 999: return 'f'
            if self.targetMismatch1 < 999 and self.targetMismatch2 < 999: return 't'

            # pair not mapped

            if self.filterMismatch1 == 999 and self.filterMismatch2 == 0 and self.targetMismatch2 == 999 and self.targetMismatch1 == 0:
                return 'c'
            if self.filterMismatch2 == 999 and self.filterMismatch1 == 0 and self.targetMismatch1 == 999 and self.targetMismatch2 == 0:
                return 'c'

            if self.filterMismatch1 < 999 and self.targetMismatch1 == 999: return 'f'
            if self.filterMismatch2 < 999 and self.targetMismatch2 == 999: return 'f'
            if self.targetMismatch1 < 999 and self.filterMismatch1 == 999: return 't'
            if self.targetMismatch2 < 999 and self.filterMismatch2 == 999: return 't'

        return 'i'

    def categorize(self):
        return self.categorizeLoose()

    def __repr__(self):
        return "(%s %d %d) (%s %d %d)" % (self.filterPaired, self.filterMismatch1, self.filterMismatch2, self.targetPaired, self.targetMismatch1, self.targetMismatch2)
        

def simpleFastqReader(filename):
    if filename.endswith(".gz"):
        f = gzip.open(filename, "rb")
    else:
        f = open(filename)
    lines = []
    for line in f:
        lines.append(line.rstrip())
        if len(lines) == 4:
            assert lines[2].startswith("+"), "fastq reader got out of phase"
            read = lines[0][1:]
            seq = lines[1]
            qual = lines[3]
            lines = []
            yield read, seq, qual
    f.close()

def fullqname(r):
    """append read number to qname from BAM file"""
    return r.qname + ("/2" if r.is_read2 else "/1")

def filterFastq(categories, infile, outfile, unalignedfile, chimerafile=None):
    total = 0
    unalignedCount = 0
    targetCount = 0
    filteredCount = 0
    chimeraCount = 0
    out = open(outfile, "w")
    unaligned = open(unalignedfile, "w")
    if chimerafile:
        chimera = open(chimerafile, "w")
    for hdr, seq, qual in simpleFastqReader(infile):
        acc = hdr.split()[0]
        idx = acc.find('/')
        if idx > 0: acc = acc[:idx]
        if acc not in categories:
            print >>unaligned, "@%s\n%s\n+\n%s" % (hdr, seq, qual)
            unalignedCount += 1
        elif categories[acc] == 't':
            print >>out, "@%s\n%s\n+\n%s" % (hdr, seq, qual)
            targetCount += 1
        elif categories[acc] == 'c':
            if chimerafile:
                print >>chimera, "@%s\n%s\n+\n%s" % (hdr, seq, qual)
            chimeraCount += 1
        else:
            filteredCount += 1
        total += 1
        if total % 1000000 == 0:
            print "Reading Target Fastq %d %d %d (%.1f%%) %d %d..." % (total, targetCount, filteredCount, filteredCount*100/total, chimeraCount, total - targetCount - filteredCount - chimeraCount)
    out.close()
    unaligned.close()
    if chimerafile:
        chimera.close()

def countIndels(cigar):
    return sum([size for op, size in cigar if op in (1, 2)])

if len(sys.argv) < 4:
    print "Usage: %s outputPrefix filter.bam target.bam [target_r1.fq [target_r2.fq]]" % (sys.argv[0],)
    sys.exit(1)

outputPrefix = sys.argv[1]
filterBam = sys.argv[2]
targetBam = sys.argv[3]
targetFastq1 = None
targetFastq2 = None

outputTargetBam = "%s.bam" % (outputPrefix,)
outputFilterBam = "%s_excluded.bam" % (outputPrefix,)
outputChimeraFastq = "%s_chimera.fq" % (outputPrefix,)
outputFilterAmbiguousBam = "%s_filter_ambiguous.bam" % (outputPrefix,)
outputTargetAmbiguousBam = "%s_target_ambiguous.bam" % (outputPrefix,)
outputFastq1 = None
outputFastq2 = None
chimeraFastq1 = None
chimeraFastq2 = None
unalignedFastq1 = None
unalignedFastq2 = None

if len(sys.argv) >= 5:
    targetFastq1 = sys.argv[4]
    outputFastq1 = "%s_filtered_r1.fq" % (outputPrefix,)
    unalignedFastq1 = "%s_unaligned_r1.fq" % (outputPrefix,)

    
if len(sys.argv) >= 6:
    targetFastq2 = sys.argv[5]
    outputFastq2 = "%s_filtered_r2.fq" % (outputPrefix,)
    unalignedFastq2 = "%s_unaligned_r2.fq" % (outputPrefix,)
    # chimera detection only makes sense for paired-end reads
    chimeraFastq1 = "%s_chimera_r1.fq" % (outputPrefix,)
    chimeraFastq2 = "%s_chimera_r2.fq" % (outputPrefix,)

wouldOverwrite = []
for filename in (outputTargetBam, outputFastq1, outputFastq2):
    if not filename: continue
    if os.path.exists(filename): wouldOverwrite.append(filename)
if wouldOverwrite:
    print >>sys.stderr, "ERROR: would overwrite output file(s)", wouldOverwrite
    sys.exit(1)

logfreq = 1000000
limit = None
seen = {}

# TODO: sanity check that the two BAM files have the same ref @SQ
total = 0
filterAlignment = pysam.Samfile(filterBam, 'rb') # Remove reads aligned in this file
for r in filterAlignment.fetch():
    if r.is_unmapped: continue
    if r.qname not in seen: seen[r.qname] = AlignmentRecord()

    if r.is_paired:
        seen[r.qname].readPaired = True
        if r.is_proper_pair: seen[r.qname].filterPaired = True

    nm = r.opt('NM')
    if r.is_paired and r.is_read2:
        seen[r.qname].filterMismatch2 = min(nm, seen[r.qname].filterMismatch2)
    else:
        seen[r.qname].filterMismatch1 = min(nm, seen[r.qname].filterMismatch1)

    total += 1
    if total % logfreq == 0:
        print "Reading Filter BAM %d ..." % (total, )
    if limit and total > limit: break
filterAlignment.close()

total = 0
targetAlignment = pysam.Samfile(targetBam, 'rb') # Keep reads that match better in this file
for r in targetAlignment.fetch():
    if r.is_unmapped: continue

    total += 1
    if total % logfreq == 0:
        print "Reading Target BAM %d ..." % (total, )
    if limit and total > limit: break

    if r.qname not in seen: continue

    assert r.is_paired == seen[r.qname].readPaired

    if r.is_paired:
        if r.is_proper_pair: seen[r.qname].targetPaired = True

    nm = r.opt('NM')

    if r.is_paired and r.is_read2:
        seen[r.qname].targetMismatch2 = min(nm, seen[r.qname].targetMismatch2)
    else:
        seen[r.qname].targetMismatch1 = min(nm, seen[r.qname].targetMismatch1)

targetAlignment.close()

total = 0
filteredCount = 0
chimeraCount = 0
targetAlignment = pysam.Samfile(targetBam, 'rb') # Keep reads that match better in this file
outTarget = pysam.Samfile(outputTargetBam, 'wb', template=targetAlignment)
outAmbiguous = pysam.Samfile(outputTargetAmbiguousBam, 'wb', template=targetAlignment)

categories = {}

for r in targetAlignment.fetch():
    if r.is_unmapped: continue

    category = None
    if not r.qname in seen:
        category = 't'
    else:
        category = seen[r.qname].categorize()

    categories[r.qname] = category # save categorization for fastq filtering

    if category == 't':
        outTarget.write(r)
    elif category == 'i':
        outAmbiguous.write(r)
    elif category == 'f':
        filteredCount += 1
    elif category == 'c':
        # print >>outChimera, "@%s/%d\n%s\n+\n%s" % (r.qname, 2 if r.is_read2 else 1, r.seq, r.qual)
        chimeraCount += 1

    total += 1
    if total % logfreq == 0:
        print "Rereading Target BAM %d %d (%.1f%%) chimera = %d ..." % (total, filteredCount, filteredCount*100/total, chimeraCount)
outTarget.close()
targetAlignment.close()

total = 0
filteredCount = 0
filterAlignment = pysam.Samfile(filterBam, 'rb') # Remove reads aligned in this file
outFilter = pysam.Samfile(outputFilterBam, 'wb', template=filterAlignment)
outAmbiguous = pysam.Samfile(outputFilterAmbiguousBam, 'wb', template=filterAlignment)
for r in filterAlignment.fetch():
    if r.is_unmapped: continue

    if r.qname in categories:
        category = categories[r.qname]
    else:
        if r.qname in seen:
            category = seen[r.qname].categorize()
        else:
            category = 'f'
        categories[r.qname]  = category

    if category == 'f':
        filteredCount += 1
        assert r.qname in categories
        outFilter.write(r)
    elif category == 'i':
        outAmbiguous.write(r)

    total += 1
    if total % logfreq == 0:
        print "Rereading Filter BAM %d %d (%.1f%%) ..." % (total, filteredCount, filteredCount*100/total)
outFilter.close()
filterAlignment.close()

if outputFastq1:
    filterFastq(categories, targetFastq1, outputFastq1, unalignedFastq1, chimeraFastq1)

if outputFastq2:
    filterFastq(categories, targetFastq2, outputFastq2, unalignedFastq2, chimeraFastq2)
