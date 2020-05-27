#!/usr/bin/perl 
use strict;
use FindBin qw($Bin);
die "Usage: <solar.tab.best>!\n"
unless @ARGV ;
my ($source)=@ARGV;
######################################
my %list;
open I,"$source";
my %tmp;
while(<I>){
	chomp;
	my @a=split /\t/;
	$a[11]/=$a[4];
	#if($a[4] >0.5 and  $a[10] >0.5 and $a[12] >60 and $a[11] >200){
	if( ($a[4] >0.5 or  $a[10] >0.5) and $a[12] >60 and $a[11] >100){
		push @{$list{$a[6]}} ,[@a]  unless exists $tmp{$a[0]};
		$tmp{$a[0]}++;
	}
}
close I;
foreach my $gene(keys %list){
	my $n=0;
	my $out='';
	my @identity;
	my @ids;
	my $pscreen;
	foreach my $a( sort {@$b[-2]  <=> @$a[-2] } @{$list{$gene}}){
		$out.=join "\t",@$a; 
#		$out.="#\n";
		$pscreen.=join "\t",@$a,"\n";
	#	next if @$a[-1] == $identity[-1];
		push @ids,@$a[0]; 
	#	push @identity,@$a[-1];
		$n++;
#		print "$out\n";
		last if $n>5;
	}	
	if($n>0 ){
#		print "$pscreen";
		my $div= abs ($identity[0] - $identity[1]);
		#print "$out#$gene\t$ids[0]\t$ids[1]\n" if $div <5;;
		print "$gene\t$ids[0]\t$ids[1]\n"  if $div < 30;;
	}
#	print "#########\n";
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
