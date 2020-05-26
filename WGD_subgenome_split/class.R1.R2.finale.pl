#!/usr/bin/perl 
use strict;
use FindBin qw($Bin);
die "Usage: <solar.infor.best>!\n"
unless @ARGV ;
my ($source)=@ARGV;
open Log ,">$source.log";
#################################gt80###############

my %gt80;
my $cutoff=0.8;
#my $cutoff=0.6;
my @cluster;
open I,"$source";
while(<I>){
	chomp;
	my @a=split /\t/;
	if( ($a[3] > $cutoff  or  $a[4] > $cutoff) and $a[17] > 8000  ){
		push @{$gt80{$a[7]}},[ @a];
	}
}
close I;
my %class1;
foreach my $ctg(sort keys %gt80){
	foreach my $l(sort { $b->[17] <=> $a->[17] } @{$gt80{$ctg}}){
		my @a=@$l;
		my $cov= $ctg eq $a[7] ? $a[3] : $a[4];
		next if $cov< $cutoff ;
		print Log "good\t";
		print Log join "\t",@a;print Log "\n";
		unless(exists $class1{$a[7]} or exists $class1{$a[12]}){
			@{$class1{$a[7]}{$a[12]}}=@a;
		}
		last;
	}
}
############################aln reliable##########
my %good;
my %check;
open I,"$source";
my $i=0;
my %bed;
open O ,">$source.bed";
while(<I>){
	chomp;
	my @a=split /\t/;
	if( ($a[3] < $cutoff  and  $a[4] < $cutoff) and ($a[17] > 20000)){
#remove inter alignment;
		my $L1 = $a[9]  < ($a[8]-$a[10])  ? $a[9] : ($a[8]-$a[10])  ; 	
		my $L2 = $a[14] < ($a[13]-$a[15]) ?  $a[14]  : ($a[13]-$a[15]); 	
		my $flag=0;	
		if($L1 <20000 ){$flag++;}
		if($L2 <20000 ){$flag++;}
		if($flag <2){
			next;
		}
		unless(exists $class1{$a[7]} or exists $class1{$a[12]}){# or exists $check{$a[7]}{$a[12]} or exists $check{$a[12]}{$a[7]}){
			$check{$a[7]}{$a[12]}++;
			$check{$a[12]}{$a[7]}++;
#push @{$good{$a[7]}},[@a];
#push @{$good{$a[12]}},[@a];
			$i++;
			print O "$a[7]\t$a[9]\t$a[10]\tc$i.1\n";
			print O "$a[12]\t$a[14]\t$a[15]\tc$i.2\n";
			@{$bed{"c$i.1"}}=@a;
			@{$bed{"c$i.2"}}=@a;
		}
	}
}
close I;
close O;
###########cluster for repeat node  detect############
`sort -k 1,1 -k 2,2n $source.bed > $source.sort.bed;bedtools cluster -d "-12000"  -i $source.sort.bed > $source.sort.bed.cluster`;
`bedtools intersect   -wao -a $source.sort.bed.cluster   -b $source.sort.bed.cluster > $source.sort.bed.cluster.interval`;

my %inter;
open I ,"$source.sort.bed.cluster.interval";
open O ,">$source.sort.bed.cluster.interval.tab";
while(<I>){
	chomp;
	my @a=split /\t/;
	if($a[3] ne $a[8]){
		my $cov1=abs $a[-1]/($a[2]-$a[1]);
		my $cov2=abs $a[-1]/($a[7]-$a[6]);
		if($cov1 >0.8 or $cov2>0.8){
			$inter{$a[4]}{$a[3]}{$a[8]}++;
			$inter{$a[4]}{$a[8]}{$a[3]}++;
			print O "$a[3]\t$a[8]\n";
			print O "$a[8]\t$a[3]\n";
		}
	}
}
close O;
close I;
`mcl   $source.sort.bed.cluster.interval.tab  -I 1.2 --abc -o $source.sort.bed.cluster.interval.tab.cluster`;
my %clu_inter;
my $i=0;
open I ,"$source.sort.bed.cluster.interval.tab.cluster";
while (my $clu=<I>){
	chomp;
	$i++;
	my @a=split /\s+/,$clu;	
	foreach my $x(@a){
	 $clu_inter{$x}=$i if $x;
	}
}
close I;
$i=0;

my %lc;
open I ,"$source.sort.bed.cluster";
while(<I>){
	chomp;
	my @a=split /\t/;
	@{$lc{$a[-1]}{$a[-2]}}=@a;;
}
close I;
####cluster covert to subcluster;
open O ,">$source.sort.bed.cluster.sub";
foreach my $lc (sort {$a <=> $b} keys %lc){
	my %sub;
	foreach my $aln(sort keys %{$lc{$lc}} ){
		if(exists $clu_inter{$aln}){
			$sub{$aln}=$clu_inter{$aln};
		}else{
			$sub{$aln}=1;
		}
	}
	my $u=0;
	foreach my $sc(sort keys %{$lc{$lc}}){
		my @a=@{ $lc{$lc}{$sc} };
		my $lc1='';
		if(exists $sub{$sc}){
			$lc1="$lc.s$sub{$sc}";
		}else{
			$lc1="$lc.u$u";
			$u++;
		}
		print O join "\t",@a,"$lc1";print O "\n";
	}
}
close O;
################index cluster##############
my %cluster;
my %aln2c;
my %lc2;
my %sc;
open I ,"$source.sort.bed.cluster.sub";
while(<I>){
	chomp;
	my @a=split /\t/;
	$lc2{$a[-1]}{$a[-3]}++;
	$sc{$a[-3]}{$a[-1]}++;
	$aln2c{$a[0]}{$a[1]}{$a[2]}=$a[-1];
}
close I;
##########cluster1 and cluster alignment ###########
foreach my $lc(sort keys %lc2){
	foreach my $sc( sort keys %{$lc2{$lc}} ){
		my @a=@{$bed{$sc}};		
		my $c1=$aln2c{$a[7]}{$a[9]}{$a[10]};
		my $c2=$aln2c{$a[12]}{$a[14]}{$a[15]};
		my $lc2= $c1 eq $lc ? $c2:$c1;
		unshift  @a,"$lc2";
		push @{$cluster{$lc}},[@a];

	}
}

my %class2;
#######get best pair cluster#####################
foreach my $c(sort keys %cluster){
	my $n=scalar @{$cluster{$c}};
	my $i=0;
	foreach my $l(sort { $b->[18] <=> $a->[18] } @{$cluster{$c}}){
		my @a=@$l;
#	print "$c\t$i\t";
#	print join "\t",@a;print "pair\n";
		print Log "Reliable\t$c:$i:$n\t";
		print Log join "\t",@a;print Log "\n";
		$i++;
		my $c2=shift @a;
		@{ $class2{$c}{$c2} }=@a if $i==1;;
#	last;
	}
}

open O, ">$source.pair.table"; 
my %tmp;
my %rbh;
foreach my $c1(sort keys %class2){
	foreach my $c2(keys %{$class2{$c1}}){
		my @a=@{$class2{$c1}{$c2}};
		if(exists $class2{$c2}{$c1} ){
			my $weight= $a[17]>20000 ? 1 : $a[17]/20000 ;	
			print O "$a[7]\t$a[12]\t$weight\n";
			print O "$a[12]\t$a[7]\t$weight\n";
			$tmp{$c1}++;		
			$tmp{$c2}++;
			@{$rbh{$a[7]}{$a[12]}}=@a;
			@{$rbh{$a[12]}{$a[7]}}=@a;
			print Log "Reliable.pair\t$c1\t$c2#\t",join "\t",@a; print Log "\n";
		}else{
			print Log "Reliable.diff\t$c1\t$c2#\t",join "\t",@a; print Log "\n";
		}
	}
}
%tmp=();
close O;
`mcl   $source.pair.table  -I 1.2 --abc -o $source.pair.table.cluster`;

######################cluaster 2 R1 R2################
my %R;
open I ,"$source.pair.table.cluster";
while(<I>){
	chomp;
	my @a=split /\s+/;
##find single node##############	
	my $snode='';
	my %node;
	print Log "cluster:\t";print Log join "\t",@a; print Log "\n";
	foreach my $ctg(@a){
		my $n=scalar (keys %{$rbh{$ctg}});
		print Log "$ctg\t$n;";
		$node{$n}{$ctg}++;
	}	
	foreach my $n(sort {$a <=> $b} keys %node ){
		$snode=(sort {$a <=> $b} keys %{$node{$n}})[0];
		last;
	}
	print Log "$snode\n";
	$R{$snode}=1;
	my $i=0;
#assign node class ###########
	while($snode){
		my $tm;
		last unless exists $rbh{$snode};
		foreach my $node(keys %{$rbh{$snode}}){
			next if exists $R{$node};
			my $tag= $R{$snode} == 1 ? 2:1;
			$R{$node}=$tag;
			$tm=$node;
		}
		$snode=$tm;
		$i++;
	}
}
close I;

foreach my $ctg1 (sort keys %class1){
	foreach my $ctg2 (sort keys %{$class1{$ctg1}}){
		if(exists $R{$ctg2}){
			my $tag= $R{$ctg2} == 1 ? 2:1;
			$R{$ctg1}=$tag;
		}else{
			$R{$ctg2}=1;
			$R{$ctg1}=2;
		}
	}
}
#################print all classsifiction###############
open O,">$source.class";
foreach my $ctg( sort keys %R){
	print O  "$ctg\tR$R{$ctg}\n";	
}
close Log;
close O;
##############################################################################

##############################################################################
sub class{
	my ($class,$chr1,$chr2)=@_;
	my %class;
	if(exists $$class{$chr1} and exists $$class{$chr1} ){
		return 0;
	}elsif( exists $class{$chr1} ){
		my $tag=$class{$chr1} ==1 ? 2 : 1;
		$class{$chr2}=$tag;
	}elsif( exists $class{$chr2} ){
		my $tag=$class{$chr2} ==1 ? 2 : 1;
		$class{$chr1}=$tag;
	}else{
		if($chr1 > $chr2){
			$class{$chr1}=1;
			$class{$chr2}=2;
		}else{
			$class{$chr2}=1;
			$class{$chr1}=2;
		}

	}
}
sub index{
	my ($hash,$file)=@_;
	open I,"$file";
	while(<I>){
		chomp;
		my @a=(split /\t/,);
		$$hash{$a[0]}= $a[1];
	}
	close I;
}
