# LASTZ alignment visualization


## What is This?

  This pipeline was used to alignment two long DNA sequence (can be mega bases) with LASTZ aliger and visulaze the alignment with repeat element ,gene structure. 
  Here is a example:
  ![example ] (https://github.com/DingDingFan/whole-genome-duplication/blob/master/LASTZ_alignment_visualize/lastz.github.log.svg) 
  
 
## pipeline dependencies


1 LASTZ:

https://github.com/lastz/lastz

2 LAST:

http://last.cbrc.jp/

3 UCSC genome browser 'kent' bioinformatic utilities:

http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64.v385/
  
Please makesure those tools on your path, remeber edit ~/.bashrc like this:

```
$ export PATH="/home/fandingding/software/last/bin/":$PATH;
```

You can install some dependence with conda:

```
conda install -c bioconda lastz
conda install -c bioconda last
conda install -c conda-forge perl

```
## How to use it ?


```

#Firstly ,you can make a draft with this:

$ perl chr_alignment.lastz.pl test.list  genome.fas

# base on the draft piture ,you can strict to regions and run 

$ perl chr_alignment.region.lastz.pl test.region.list genome.fas

```

To get better visualization, you make need modify code.

## Contact

If any problem, please mail to biocomfun@qq.com.

Thanks you very much !

## End
