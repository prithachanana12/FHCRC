#!/bin/bash
set -e
dir=`pwd`

samples="176CR_s1_ET5147 176CR_s5_ET5973 235-2_s0_ET5576 235-2_s2_ET5967 235-3_s2_ET6075 235-3_s3_ET6287"
m="mm10"

for s in ${samples}; do
out="2filterMM10.${s}.sbatch"
	echo "#!/bin/bash" > ${out}
	echo "#SBATCH --partition=largenode" >> ${out}
	echo "#SBATCH -n 1" >> ${out}
	echo "#SBATCH -c 16" >> ${out}
	echo "#SBATCH --mem=48G" >> ${out}
	echo "#SBATCH -t7-0" >> ${out}
	echo "ml Python/2.7.14-foss-2016b-fh1" >> ${out}
	echo "cd ${dir}" >> ${out}
	echo "time ./FilterBamBySpecies.py ${s} tophat.${m}/${s}.bam tophat/${s}.bam > ${s}.log 2>&1" >> ${out}
done
