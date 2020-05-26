#!/usr/bin/perl 
use strict;
use FindBin qw($Bin);
die "Usage: <2bit.list genome.fai>!\n"
unless @ARGV ;
my $list =shift @ARGV;
######################################
my @files;
open I,"$list";
while(<I>){
	chomp;
	push @files,$_;
}
close I;
#############################################################
my $i=0;
my $fai=shift @ARGV;
my %hash;
foreach my $f1(@files){
	$i++;
	my $j=0;
	foreach my $f2(@files){
		$j++;
		#next  unless $f1 eq $f2;
		next if exists $hash{$i}{$j};
		next if exists $hash{$j}{$i};
		my $dir="$ENV{PWD}/$i.$j";
		my $shell="mkdir -p $dir; cd $dir;";
		#$shell.="lastz $f1\[multi\] $f2\[multi\]  --seed=12of19 --notransition --chain --gapped --gap=400,30 --hspthresh=2000 --gappedthresh=3000 --ydrop=3400 --gappedthresh=4000  --inner=2000 --format=axt   > lastz.axt";
		$shell.="perl $Bin/axt.filt.same.pl   lastz.axt  > lastz.ue.axt ; ";
		$shell.="axtChain  -linearGap=medium   lastz.ue.axt $f1 $f2  lastz.chain 2>/dev/null 1>/dev/null;";
		$shell.="chainNet  lastz.chain $fai  $fai target.net query.net ;";
		$shell.="netSyntenic  target.net  target.out.net;netFilter  -minAli=100 target.out.net 1> target.out.filt.net 2>/dev/null ; ";
		$shell.="netToAxt target.out.filt.net lastz.chain $f1 $f2  out.axt;";
		$shell.="axtToMaf out.axt   $fai $fai   out.maf; maf-convert blasttab  -j 500  out.maf  > out.maf.tab  ; perl $Bin/MafToM8.pl out.maf.tab  >out.un.m8;";
		print "$shell\n";	
		$hash{$i}{$j}+=1;
		$hash{$j}{$i}+=1;
	}
close I;
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
