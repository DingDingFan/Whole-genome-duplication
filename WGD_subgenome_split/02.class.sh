
basedir=`cd $(dirname $0); pwd -P`
cat LASTZ_run/*/out.axt |perl ~/bin/axt.merge.pl  -  |axtSort  /dev/stdin  out.sort.axt
axtChain  -linearGap=medium out.sort.axt OUT.fa.2bit OUT.fa.2bit all.chain 2>/dev/null 1>/dev/null
chainNet  all.chain ../genome.fas.fai  ../genome.fas.fai target.net query.net ;
netSyntenic  target.net  target.out.net;
netFilter -syn  -minAli=50 target.out.net 1>target.out.filt.net 2>/dev/null ; 
netToAxt target.out.filt.net all.chain ./OUT.fa.2bit OUT.fa.2bit filt.out.axt
xtToMaf filt.out.axt   ../genome.fas.fai ../genome.fas.fai   out.filt.maf; 
maf-convert blasttab  -j 500  out.filt.maf | perl /Raid/raid5/Project/fandingding/Tibet_fish/Schizothorax/update.git/WGD_subgenome_split/MafToM8.pl - > all.out.m8
sort -k 1,1 -k 2,2 -k 7,7n all.out.m8 > all.sort.m8;

perl $basedir/solar/solar.pl -cn 50000  -f m8  -v all.sort.m8 > all.out.solar;
perl $basedir/solar_add_LenbyFai.pl all.out.solar genome.fas.fai > all.out.solar.infor;
perl $basedir/solar.infor.best.pl all.out.solar.infor > all.out.solar.infor.best
perl $basedir/class.R1.R2.finale.pl all.out.solar.infor.best 
######

echo "all.out.solar.infor.best.class are the result" ;
