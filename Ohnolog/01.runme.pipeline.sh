in=$1 ;# instresting pep 
database=$2;#
#database was zebrafish proteome ########
################
basedir=`cd $(dirname $0); pwd -P`
################### all-vs-all blastp ############
ln -s $in ./query.pep
ln -s $database ./target.pep;
makeblastdb  -in target.pep -dbtype prot  -parse_seqids
blastp -db target.pep -query $in -out query.pep.m8 -evalue 1e-10 -outfmt  6 -num_threads 10 
################deal blastp result#################
i="query.pep.m8";
perl $basedir/solar/solar.pl -a prot2prot -f m8 $i >$i.solar ; ### deal local aligment to global alignment ############
perl $basedir/solar_add_id.len/solar_add_realLen.pl $i.solar query.pep   >$i.cor; 
perl $basedir/solar_add_identity.pl --solar $i.cor --m8 $i  >$i.solar.cor.idAdd ;
#########
perl  $basedir/blast_best.tab.pl  $i.solar.cor.idAdd > $i.best # get the best gene's alignment to zebrafish ###########
######
#get the two best hit for zebrafish genes with critirals
perl $basedir/get.Ohnolog.v2.pl $i.best > $i.Ohnolog ;


