# Subgenome_split

## What is This?

  This pipeline was used to split the sub-genome for whole genome dupliction assembly.

## How it works?
  Firstly ,it do a all-vs-all genome alignment using LASTZ.The alignments of the same contig were removed.

  Secondly , If two matching alignments next to each other are close enough, they are joined into one segment using UCSC Genome Browser tools axtChain (-linearGap=loose). During the alignment, every genomic fragment can match with several others, and certainly we want to keep the best one. This is done by chainNet. Then we add the synteny information with netSyntenic. And net was deal with netFilter(-syn) to filter non-synteny block. 

  Then based on the net information of homologues pairs, if 80% (cat be change to 60%) percent of one sequence were aligned, then we defined the long sequence as R1 and opposite sequence as R2, for the unclass sequence we treated with coverage percentage less than 80%.we cluster the alignment and liner the relationship to defined R1 and R2.

## pipeline dependencies


1 LASTZ: 

  https://github.com/lastz/lastz

2 LAST: 

  http://last.cbrc.jp/

3 MCL :  

  https://micans.org/mcl/

4 UCSC genome browser 'kent' bioinformatic utilities:

  http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64.v385/

5 bedtools:

  https://bedtools.readthedocs.io/en/latest/
  
  
Please makesure those tools on your path, remeber edit ~/.bashrc like this:

```

$ export PATH="/home/fandingding/software/last/bin/":$PATH;

```

## How to use it ?

Firstly ,"sh 01.self.genome.alignment.sh your.genome.fasta" ; it will generate 01.batch.lastz.sh you can modify the shell and parelled the  01.batch.lastz.sh to use more CPU .

Secondly, "sh 02.class.sh" all.out.solar.infor.best.class will be you classfication resut. 

Note: the R1 and R2 were split randomly !!!

```
sh 01.self.genome.alignment.sh your.genome.fasta

sh 02.class.sh

```

## Contact

If any problem, please mail to biocomfun@qq.com.

Thanks you very much !

## End



