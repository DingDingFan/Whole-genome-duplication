#!/usr/bin/perl -w
use strict;
die "Usage: <solar result> <fai>\n" unless @ARGV >= 2;
my $solar_file = shift @ARGV;

my %seqLen;
foreach my $fasta_file (@ARGV) {
	open IN, $fasta_file;
	while (<IN>) {
		my @a=split /\t/;
		my $id=$a[0];
		my $len=$a[1];
		$seqLen{$id} = $len;	
	}
	close IN;
}

open IN, $solar_file;
while (<IN>) {
	chomp;
	my @info = split /\t/;
	next if $info[10] < 5000;
	$info[1] = $seqLen{$info[0]};
	$info[6] = $seqLen{$info[5]}; #if $seqLen{$info[5]};
	my $cov1=abs ($info[2]-$info[3])/$info[1];
	my $cov2=abs ($info[7]-$info[8])/$info[6];
	my $flen= $cov1 > $cov2 ? $info[1] :$info[6];
	my $fchr= $cov1 > $cov2 ? $info[0] :$info[5];
	my $len1=abs $info[2]-$info[3]+1;
	my $len2=abs $info[7]-$info[8]+1;
	my $score= $len1 > $len2 ?  $info[10]/$len2 : $info[10]/$len1;
	my $out = join "\t", @info;
	print "$score\t$fchr\t$flen\t$cov1\t$cov2\t$len1\t$len2\t$out\n";
}
close IN;
