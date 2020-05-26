#!/usr/bin/perl 
use strict;
use FindBin qw($Bin);
die "Usage: <solar.infor.best>!\n"
unless @ARGV ;
my ($source)=@ARGV;
open Log ,">$source.log";
#################################gt80###############

my %gt80;
my @cluster;
open I,"$source";
while(<I>){
	chomp;
	my @a=split /\t/;
	if( ($a[3] >0.7 or  $a[4] >0.7) and $a[17] > 8000  ){
		push @{$gt80{$a[7]}},[ @a];
	}
}
close I;
my %class1;
foreach my $ctg(sort keys %gt80){
	foreach my $l(sort { $b->[17] <=> $a->[17] } @{$gt80{$ctg}}){
		my @a=@$l;
		my $cov= $ctg eq $a[7] ? $a[3] : $a[4];
		next if $cov<0.7;
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
	if( ($a[3] <0.7 and  $a[4] <0.7) and ($a[17] > 20000)){
		#remove inter alignment;
		my $flag1 = ($a[9] <5000 or ($a[8]-$a[10]) <5000 )? 1:0; 	
		my $flag2 = ($a[14] <5000 or ($a[13]-$a[15]) <5000 )? 1:0; 	
		unless( $flag1 or $flag2){
			next;
		}
		unless(exists $class1{$a[7]} or exists $class1{$a[12]}){# or exists $check{$a[7]}{$a[12]} or exists $check{$a[12]}{$a[7]}){
			$check{$a[7]}{$a[12]}++;
			$check{$a[12]}{$a[7]}++;
			#push @{$good{$a[7]}},[@a];
			#push @{$good{$a[12]}},[@a];
			$i++;
			print O "$a[7]\t$a[9]\t$a[10]\tc$i\n";
			print O "$a[12]\t$a[14]\t$a[15]\tc$i\n";
			@{$bed{"c$i"}}=@a;
		}
	}
}
close I;
close O;
###########cluster for repeat node  detect############
`sort -k 1,1 -k 2,2n $source.bed > $source.sort.bed;bedtools cluster -d "-12000"  -i $source.sort.bed > $source.sort.bed.cluster`;
my %cluster;
my %sc;;
my %lc;
my %aln2c;
open I ,"$source.sort.bed.cluster";
while(<I>){
	chomp;
	my @a=split /\t/;
	$lc{$a[-1]}{$a[-2]}++;
	$sc{$a[-2]}{$a[-1]}++;
	$aln2c{$a[0]}{$a[1]}{$a[2]}=$a[-1];
	#next if exists $tmp{$a[-2]};
#	push @{$cluster{"$a[-1]"}},[ @{ $bed{$a[-2]} } ];
}
close I;
my %tmp;
foreach my $lc (sort {$a <=> $b} keys %lc){
	foreach my $sc(sort keys %{$lc{$lc}}){
		push @{$cluster{$lc}},[ @{ $bed{$sc}} ] unless exists $tmp{$sc} ;	
		$tmp{$sc}++;
		my @a=@{ $bed{$sc} };
		my $c1=$aln2c{$a[7]}{$a[9]}{$a[10]};
		my $c2=$aln2c{$a[12]}{$a[14]}{$a[15]};
		my $lc2= $c1 eq $lc ? $c2:$c1;
			
		print "#$lc\t$c2\t$sc#"; print join "\t",@a;print "\n";
		foreach my $lc2(sort keys %{$sc{$sc}}){
			next if $lc eq $lc2;
			foreach my $sc2 (sort keys %{$lc{ $lc2 }}){
				next if $sc eq $sc2;
				push @{$cluster{$lc}},[ @{ $bed{$sc2}} ] unless exists $tmp{$sc2} ;	
				$tmp{$sc2}++;
			}
		}
	}
}



my %class2;
open O, ">$source.pair.table"; 
foreach my $c(sort keys %cluster){
	my $i=1;
	my $n=scalar @{$cluster{$c}};
	foreach my $l(sort { $b->[17] <=> $a->[17] } @{$cluster{$c}}){
		my @a=@$l;
	#	print "$c\t$i\t";
	#	print join "\t",@a;print "pair\n";
		print Log "Reliable\t$c:$i:$n\t";
		print Log join "\t",@a;print Log "\n";
		@{ $class2{$a} }=@a;
		my $weight= $a[17]>100000 ? 1 : $a[17]/100000 ;	
		print O "$a[7]\t$a[12]\t$weight\n";
		print O "$a[12]\t$a[7]\t$weight\n";
		#last;
		$i++;
	}
}
close O;
`~/software/DNA_evolution/Plant/01.gene_family/bin/software/mcl  $source.pair.table  --abc -o $source.pair.table.cluster`;

close Log;
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
