# Ohnolog detect

## What is This?

  This pipeline was used to detect Ohnolog genes based on amino acid sequence alignments to a reference protomes , such as we use zebrafish in the S o’connori genome project. 
## How it works?
  The S o’connori had a recently (~ 1.23 mya) wholge genome duplication, the gene content should be double compare to zebrafish . Apprently, the orthorlogy genes of zebrafish should have two copy in the  S o’connori genome. 
  
  Firstly ,we do amino acid alignment using BLAST with (-e 1e-10),the reference genome was used as database.
  
  Secondly,we detect t 2:1 the orthorlogues according to the single best reciprocal hit.
  
  Here, we recommend to remove Ohnolog on the same contigs which mostly be generated from tandem duplication. 
  
 
## pipeline dependencies


1 BLAST: 

  Protein-Protein BLAST 2.6.0+


  
Please makesure those tools on your path, remeber edit ~/.bashrc like this:

```

$ export PATH="/home/fandingding/software/last/bin/":$PATH;

```

## How to use it ?


```

$ sh 01.runme.pipeline.sh SCHoco.pep zebrafish.pep


```

## Contact

If any problem, please mail to biocomfun@qq.com.

Thanks you very much !

## End



