#!/usr/bin/perl 
use strict;
#use FindBin qw($Bin/fdd_package/);
die "Usage: <solar>!\n"
unless @ARGV ;
######################################
my $source=shift @ARGV;
open I,"$source";
while(<I>){
	chomp;
	my @a=split /\t/;
	my $iden= ($a[10]/2) / ($a[3]-$a[2])*100;
	my $aln=int $a[10]/2;
	print "$a[0]\t$a[5]\t$iden\t$aln\t0\t0\t$a[2]\t$a[3]\t$a[7]\t$a[8]\t$a[10]\n" if $a[4] eq '+';
	print "$a[0]\t$a[5]\t$iden\t$aln\t0\t0\t$a[3]\t$a[2]\t$a[7]\t$a[8]\t$a[10]\n" if $a[4] eq '-';
	

}
close I;
