#!/usr/bin/perl 
use strict;
use FindBin qw($Bin);
use lib "$Bin/";
use Lastz;
die "tab.alignment_conver.tab repeat.gff gene.structure.gffs zebrafish.gff self.gff prefix\n" unless @ARGV>=2;
#################################################
my ($S1,$T1,$S2,$T2);
my %tab;
Lastz::readTab(\%tab,$ARGV[0]);
my %repeat;
Lastz::readGFF(\%repeat,"/home/fandingding/Schizothorax/02.genome_anotation/repeat_elements/stat/SCHyou.all.gff.nr.gff");
my %gff;
Lastz::readGFF(\%gff,"/home/fandingding/Schizothorax/02.genome_anotation/Maker/SCHyou/longest.gff");
my %svgff;
#Lastz::readGFF(\%svgff,"/home/fandingding/ssd/Project/liefuyu/R1.R2.sv/all.sv.filt.rename.gff");
#my %sgff;
#Lastz::readGFF(\%sgff,"/home/fandingding/raid5/Project/fandingding/lastz/deal/stat/GENE/singleton/single_check/SCHoco.pep.fa.solar.genewise.rename.gff.nr.gff");
my $prefix=$ARGV[-1];
######################################
my (@s1,@s2,@t1,@t2);
foreach my $chr1(keys %tab){
	foreach my $chr2(keys %{$tab{$chr1}}){
		foreach my $p(@{$tab{$chr1}{$chr2}}){
			my @a=@$p;
			push @s1,$a[6]; push @t1,$a[7];
			push @s2,$a[8]; push @t2,$a[9];
		}
	}
}
$S1= (sort {$a <=> $b} @s1)[0] - 2000;
$S2= (sort {$a <=> $b} @s2)[0] - 2000;
$T1= (sort {$a <=> $b} @t1)[-1] + 2000;
$T2= (sort {$a <=> $b} @t2)[-1] + 2000;
print "raw:\t$S1,$T1,$S2,$T2\n";
$S1= $S1<0 ? 0 : $S1;
$S2= $S2<0 ? 0 : $S2;
print "correct:\t$S1,$T1,$S2,$T2\n";
#($S1,$T1,$S2)=(0,2300000,6800000);
my $len= ($T1-$S1) > ($T2-$S2)? ($T1-$S1)+1: ($T2-$S2)+1;

my $pix= 2000/$len;
my $global_y=350;
################################
open FIGOUT, ">$prefix.svg" || die "cannot open";
print FIGOUT Lastz::title(2000,800,0);
#main######################################################
my $identity_legend='';
foreach my $chr1(keys %tab){
my $n=0;
my $ystart=$global_y;
foreach my $chr2(keys %{$tab{$chr1}}){
                if($n==0){
                        my $x2=100+($T1-$S1+1)*$pix;
                        print FIGOUT "<text x=\"25\" y=\"$ystart\" fill=\"black\" font-family=\"Verdana\" font-size=\"12\">".$chr1."</text>"."\n" ;
                        print FIGOUT "<line x1=\"100\" y1=\"$ystart\" x2=\"$x2\" y2=\"$ystart\" stroke=\"blue\" stroke-width=\"5\"/>"."\n";
                        print FIGOUT Lastz::axis($ystart,$S1,$T1,$pix,5,1);
                        print FIGOUT Lastz::gene($chr1,$ystart-30,$S1,$T1,$pix,\%gff,"Genes");
#                       	print FIGOUT Lastz::nucdiff($chr1,$ystart-60,$S1,$T1,$pix,\%svgff,"Detect.sv");
                        #print FIGOUT Lastz::gene($chr1,$ystart-90,$S1,$T1,$pix,\%sgff,"Self");
                        print FIGOUT Lastz::repeat($chr1,$ystart-60,$S1,$T1,$pix,\%repeat,"Transposon");
                        #&FPKM($chr1,$ystart-65,$S1,$T1,$pix,\%fpkm);
                        $ystart+=300;
                        $x2=100+($T2-$S2+1)*$pix;       
                        print FIGOUT "<text x=\"25\" y=\"$ystart\" fill=\"black\" font-family=\"Verdana\" font-size=\"12\">".$chr2."</text>"."\n" ;
                        print FIGOUT "<line x1=\"100\" y1=\"$ystart\" x2=\"$x2\" y2=\"$ystart\" stroke=\"blue\" stroke-width=\"5\"/>"."\n";
                        print FIGOUT Lastz::axis($ystart,$S2,$T2,$pix,5,0);
                        print FIGOUT Lastz::gene($chr2,$ystart+30,$S2,$T2,$pix,\%gff,"Genes");
 #                       print FIGOUT Lastz::nucdiff($chr2,$ystart+60,$S2,$T2,$pix,\%svgff,"Detect.sv");
                       # print FIGOUT Lastz::gene($chr2,$ystart+90,$S2,$T2,$pix,\%sgff,"Self");
                        print FIGOUT Lastz::repeat($chr2,$ystart+60,$S2,$T2,$pix,\%repeat,"Transposon");
                        $n++;
                }
                foreach my $p(@{$tab{$chr1}{$chr2}}){
                        my @aln=@$p;
                     	my $x11=($aln[6]-$S1+1)*$pix+100;
                        my $y1=$ystart-290;
                        my $x12=($aln[7]-$S1+1)*$pix+100;;
                        my $x21=($aln[8]-$S2+1)*$pix+100;
                        my $x22=($aln[9]-$S2+1)*$pix+100;
                        my $y2=$ystart-10;
                        (my $color,$identity_legend)= Lastz::heatmap($aln[2]); 
                        if($aln[7] >$T1 or $aln[9]>$T2 or $aln[8] <$S2){next;}
                        print FIGOUT "<polyline points=\"$x11,$y1 $x21,$y2 $x22,$y2 $x12,$y1 $x11,$y1 \" style=\"fill:$color;fill-opacity:0.8;stroke:#FFFFFF;stroke-width:0\" />"."\n";
                }
                $ystart+=300;
        }
}
print FIGOUT Lastz::Legend;
print FIGOUT $identity_legend;
print FIGOUT "</svg>";
`svg2xxx -t pdf $prefix.svg`;
