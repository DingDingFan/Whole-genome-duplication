fas=$1
ln -s $fas ./genome.fas
faToTwoBit genome.fas genome.fas.2bit
samtools faidx genome.fas
seqkit split  -p 50    -j 10 ./genome.fas
###OUT.fa.split
for i in  genome.fas.split/genome.part_*.fas
do
	faToTwoBit $i $i.2bit
done

ls $PWD/genome.fas.split/genome.part_*.fas.2bit > 2bit.list

basedir=`cd $(dirname $0); pwd -P`;

perl $basedir/lastaz.self.aln.pl 2bit.list genome.fas.fai > 01.batch.lastz.sh


mkdir LASTZ_run;

cd LASTZ_run;
######this step can be paralleled 
nohup sh 01.batch.lastz.sh &

cd ../



