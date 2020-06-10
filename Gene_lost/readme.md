# Gene Lost detect 


## What is This?

  This pipeline was used to provided the lost gene on the syteny block.Further ,we detect it on the lost region with exonerate and tlastn.
  
   Here is how it works:
  ![Result ](https://github.com/DingDingFan/whole-genome-duplication/blob/master/Gene_lost/flow1.png) 
  Gene lost events displayed on synteny blocks. The blue rectangle means gene lost, for the red rectangle block, it may be caused by other whole genome duplication, so we don’t consider about it. 
  
 
## pipeline dependencies


1 mscanX

http://chibba.agtec.uga.edu/duplication/mcscan/

2 ncbi blast

3 exonerate
 https://www.ebi.ac.uk/about/vertebrate-genomics/software/exonerate
  
Please makesure those tools on your path, remeber edit ~/.bashrc like this:

```
$ export PATH="/home/fandingding/software/last/bin/":$PATH;
```


## How to use it ?


```

#Firstly ,you should do got a collinearity file with mscan

#Then you also need a gene order file on chromosome/sequence .this can be easyly producted using gff file of Genes


perl $basedir/mscan.get.lost.gene.pl $i.gene.order $i.collinearity $i

grep -v \#  $i.lost.bed |perl -ne 'chomp; @a=split; print "$a[3]\t$a[4]\t$a[5]\t$a[2]\n";'|sort -k 1,1 -k 2,2n  > $i.sort.bed
bedtools getfasta -fi $i.fas -bed  $i.sort.bed > $i.sort.bed.fas

cd $i;
	ln -s ../$i.* ./
	perl $basedir/exonerate.lost.region.run.pl $pep $i.sort.bed.fas  $i.lost.bed	
cd ../

detail shows in the run.sh

```

To get better visualization, you make need modify code.

## Contact

If any problem, please mail to biocomfun@qq.com.

Thanks you very much !

## End

