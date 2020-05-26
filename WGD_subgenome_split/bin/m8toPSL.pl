#!/usr/bin/perl 
use strict;
use FindBin qw($Bin);
die "Usage: <m8>!\n"
unless @ARGV ;
######################################
my $i=0;
open I, shift @ARGV;
while(<I>){
	chomp;
	my @a=split /\t/;
	my $score=$a[-1]*7;
	my $strand="+";
	#$a[3]=int($a[3]/4);
	$strand="-" if $a[9] < $a[8];
	@a[6..7]=sort {$a <=> $b}@a[6..7];
	@a[8..9]=sort {$a <=> $b}@a[8..9];
	print "$a[3]\t$a[4]\t0\t0\t$a[4]\t0\t$a[5]\t0\t$strand\t"
	$i++;
}
close I;
=begin
foreach(keys %hash){
		print "$_\t$hash{$_}\n";
}
=cut
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
