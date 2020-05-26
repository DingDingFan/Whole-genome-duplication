#!/usr/bin/perl 
use strict;
use FindBin qw($Bin);
die "Usage: <axt filt same chr>!\n"
unless @ARGV ;

open I,shift @ARGV;
while(<I>){
	print if /^#/;
	if(/\d+\s+/){
		my @a=split;	
		if($a[1] eq $a[4] ){
			my $a=<I>;
			my $b=<I>;
			my $c=<I>;
		}else{print; my $a=<I>; print $a; my $b=<I>;print $b;my $c=<I>;print "$c";}
	}	
}
close I;
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
