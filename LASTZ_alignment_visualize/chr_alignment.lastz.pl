#!/usr/bin/perl 
use strict;
use FindBin qw($Bin);
die "Usage: <list fasta>!\n"
unless @ARGV ;
my ($list,$fas)=@ARGV[0,1];
######################################
my @region;
open I,"$list";
my $n=0;
while(<I>){
	chomp;
	s/\|/_/g;
	my @a=split /\s+/;
	my ($g1,$g2)=@a[0,2];
		my $dir="$ENV{PWD}/output/$g1.vs.$g2";
		
		my $shell="mkdir -p $dir; cd $dir;";
		$shell.="samtools faidx $fas $g1 > target.fasta; samtools faidx $fas $g2 > query.fasta; ";
		$shell.="faToTwoBit  target.fasta target.2bit; faToTwoBit query.fasta query.2bit;";
		$shell.="lastz  target.2bit[unmask] query.2bit[unmask]  --seed=12of19 --notransition --chain --gapped --gap=400,30 --hspthresh=2000 --gappedthresh=3000 --ydrop=3400 --gappedthresh=4000  --inner=2000 --format=axt  --filter=identity:70 > lastz.axt;";
		#$shell.="lastz  target.2bit[$a[1]..$a[2]+100%,unmask] query.2bit[$a[4]..$a[5]+100%,unmask]  --seed=12of19 --notransition --chain --gapped --gap=400,30 --hspthresh=2000 --gappedthresh=3000 --ydrop=3400 --gappedthresh=4000  --inner=2000 --format=axt  --filter=identity:70 > lastz.axt;";
		$shell.="axtChain  -linearGap=medium lastz.axt target.2bit query.2bit  lastz.chain;";
		#$sheel.=" chainFilter  -qMaxGap=2000 -tMaxGap=2000 lastz.chain > lastz.chain.filt;";
		$shell.="chainPreNet  lastz.chain $fas.fai  $fas.fai Prenet.chain;";
		$shell.="chainNet Prenet.chain  $fas.fai  $fas.fai target.net query.net;";
		$shell.="netSyntenic  target.net  target.out.net;";
		$shell.="netToAxt target.out.net Prenet.chain  target.2bit query.2bit out.axt;";
		$shell.="axtToMaf out.axt   $fas.fai $fas.fai  out.maf;~/software/last/bin/maf-convert blasttab out.maf >out.tab;";
		$shell.="perl   $Bin/lastzalignment.visualize.v2.pl out.tab $g1.vs.$g2" ;
		print "$shell\n";	
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
