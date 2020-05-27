#!/usr/bin/perl 
use strict;
use FindBin qw($Bin);
die "Usage: <list  fasta>!\n"
unless @ARGV ;
my ($list,$fas)=@ARGV[0,1];
######################################
my @region;
open I,"$list";
my $n=0;
while(<I>){
	chomp;
	my @a=split /\s+/;
	push @region,[@a];
	$n++;
}
close I;
for(my $i=0;$i<$n;$i++){
	my @g1=@{$region[$i]};
	for(my $j=$i+1;$j<$n;$j++){
		my @g2=@{$region[$j]};
		my $dir="$ENV{PWD}/output/$g1[0].$g1[1]_vs_$g2[0].$g2[1]";
		my $shell="mkdir -p $dir; cd $dir;";
		$shell.="samtools faidx $fas $g1[0] > target.fasta; samtools faidx $fas $g2[0] > query.fasta; ";
		$shell.="faToTwoBit  target.fasta target.2bit; faToTwoBit query.fasta query.2bit;";
#		$shell.="lastz  target.2bit[unmask] query.2bit[unmask]  --seed=12of19 --notransition --chain --gapped --gap=400,30 --hspthresh=2000 --gappedthresh=3000 --ydrop=3400 --gappedthresh=4000  --inner=2000 --format=axt > lastz.axt;";
		$shell.="lastz  target.2bit[$g1[1]..$g1[2]+5%,unmask] query.2bit[$g2[1]..$g2[2]+5%,unmask]  --seed=12of19 --notransition --chain --gapped --gap=400,30 --hspthresh=2000 --gappedthresh=3000 --ydrop=3400 --gappedthresh=4000  --inner=2000 --format=axt  --identity=70  > lastz.axt;";
		$shell.="axtChain  -linearGap=medium lastz.axt target.2bit query.2bit  lastz.chain; ";
		$shell.="chainPreNet  lastz.chain $fas.fai  $fas.fai Prenet.chain;";
		$shell.="chainNet -tNibDir=target.2bit -qNibDir=query.2bit Prenet.chain  $fas.fai  $fas.fai target.net query.net -linearGap=medium;";
		$shell.="netSyntenic  target.net  target.out.net;";
		$shell.="netToAxt target.out.net Prenet.chain  target.2bit query.2bit out.axt;";
		$shell.="axtToMaf out.axt   $fas.fai $fas.fai  out.maf;~/software/last/bin/maf-convert blasttab out.maf >out.tab;";
		$shell.="perl   $Bin/lastzalignment.visualize.v2.pl out.tab test";
		print "$shell\n";	
	}
}

##############################################################################
sub index{
	my ($hash,$file)=@_;
	open I,"$file";
	while(<I>){
		chomp;
		my @a=(split /\t/,);
		next unless $a[2] eq 'mRNA';
		/ID=([^;]+);/;
		@{$$hash{$1}}= @a[0,3,4];;
	}
	close I;
}
