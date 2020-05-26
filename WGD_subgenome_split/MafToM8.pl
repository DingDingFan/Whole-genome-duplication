#!/usr/bin/perl 
use strict;
#use FindBin qw($Bin/fdd_package/);
die "Usage: <maf>!\n"
unless @ARGV ;
my ($source)=@ARGV;
######################################
#system("maf-convert blasttab  $source > $source.tab");

open I,"$source";
while(<I>){
	chomp;
	my @a=split /\t/;
	my $score=2*$a[3]-$a[4]-2*$a[5];
	my @b=@a;	
	$b[0]=$a[1];
	$b[1]=$a[0];
	$b[6]=$a[8];	
	$b[7]=$a[9];	
	$b[8]=$a[6];	
	$b[9]=$a[7];	
	my $reverse=join "\t",@b;
	print "$_\t$score\n";		
	print "$reverse\t$score\n";		
}
close I;
