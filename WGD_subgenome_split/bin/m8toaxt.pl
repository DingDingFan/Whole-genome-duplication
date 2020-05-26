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
	next unless $a[-1]>1000;
	my $score=$a[-1]*7;
	my $strand="+";
	#$a[3]=int($a[3]/4);
	$strand="-" if $a[9] < $a[8];
	@a[6..7]=sort {$a <=> $b}@a[6..7];
	@a[8..9]=sort {$a <=> $b}@a[8..9];
	my $len1=$a[7]-$a[6]+1;
	my $len2=$a[9]-$a[8]+1;
	my $len=$len1>$len2?$len2:$len1;
	print "$i $a[0] $a[6] $a[7] $a[1] $a[8] $a[9] $strand  $score\n";
	print "A"x$len;print "\n";
	print "A"x$len;print "\n";
	print "\n";

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
