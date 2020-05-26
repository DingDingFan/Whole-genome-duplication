#!/usr/bin/perl 
use strict;
use FindBin qw($Bin);
die "Usage: <solar>!\n"
unless @ARGV ;
my ($source)=@ARGV;
my %aln;
my %class;
open I,"$source";
while(<I>){
	my @a=split /\t/;
	if( ($a[3] >0.8 or $a[4] >0.8)  && $a[17] >100000){
		if(exists $class{$a[7]} and exists $class{$a[7]} ){
			next;
		}elsif( exists $class{$a[7]} ){
			my $tag=$class{$a[7]} ==1 ? 2 : 1;
			$class{$a[12]}=$tag;
		}elsif( exists $class{$a[12]} ){
			my $tag=$class{$a[12]} ==1 ? 2 : 1;
			$class{$a[7]}=$tag;
		}else{
			if($a[8]> $a[13]){
				$class{$a[7]}=1;
				$class{$a[12]}=2;
			}else{
				$class{$a[12]}=1;
				$class{$a[7]}=2;
			}

		}
	}
}
close I;
foreach my $ctg(sort keys %class){
	print "$ctg\tR$class{$ctg}\n";
}
##############################################################################
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
