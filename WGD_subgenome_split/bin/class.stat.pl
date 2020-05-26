#!/usr/bin/perl 
use strict;
use FindBin qw($Bin);
die "Usage: <fai class gff busco>!\n"
unless @ARGV ;
my ($list_file,$source,$gff,$fbusco)=@ARGV;
my %len;
######################################
&index(\%len,$list_file);
my %gff;
&gff(\%gff,$gff);
my %busco;
&busco(\%busco,$fbusco);
my %class;
my %stat;
open I,"$source";
while(<I>){
	chomp;
	my @a=split /\t/;
	next unless $a[0];
	$stat{$a[1]}{"n"}++;
	$stat{$a[1]}{"sum"}+=$len{$a[0]};
	$stat{$a[1]}{"ctg"}.="\t$a[0]";
	$class{$a[0]}++;
}
close I;
foreach my $ctg(keys %len){
	unless(exists $class{$ctg}){
		my $tag="Unclass";
		$stat{$tag}{"n"}++;
		$stat{$tag}{"sum"}+=$len{$ctg};
		$stat{$tag}{"ctg"}.="\t$ctg";

	}
}


my %com;
foreach my $ctg (sort keys %gff){
	foreach my $gene (sort keys %{$gff{$ctg}} ){
		next unless exists $busco{$gene};
		$com{$ctg}{ $busco{$gene} } ++;
	}
}
my $allb='2586';
open O ,">$source.add.unclass";
foreach my $R (sort keys %stat){
	print "$source\t$R\t$stat{$R}{n}\t$stat{$R}{sum}\t";
	my @ctgs =sort (split /\t/,$stat{$R}{"ctg"});
	my %tmp;
	my ($single,$dup,$total)=qw(0 0 0);
	foreach my $ctg(@ctgs){
		print O "$ctg\t$R\t$len{$ctg}\n";
		foreach my $bgene ( keys %{$com{$ctg}}  ){
			$tmp{$bgene}++;
		}
	}
	foreach my $bgene(%tmp){
		my $n=$tmp{$bgene};
		if($n==1){ $single++ }else{$dup++ if $n>1;}
		$total++ if $n;
	}
	$single/=$allb;
	$dup/=$allb;
	$total/=$allb;
	my $miss=1-$total;
	print "$single\t$dup\t$total\t$miss\n";
	
}
close O;

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
sub gff{
	my ($hash,$file)=@_;
	open I,"$file";
	while(<I>){
		chomp;
		my @a=(split /\t|\=|\;/,);
		$a[-1]=~ s/\-[^\-]+$//;
		$$hash{$a[0]}{$a[-1]}++;
		#print "$a[0]\t$a[-1]\n";
	}
	close I;
}
sub busco{
	my ($hash,$file)=@_;
	open I,"$file";
	while(<I>){
		chomp;
		my @a=(split /\s+/,);
		$a[2]=~ s/\-[^\-]+$//;
		$$hash{$a[2]}=$a[0];
#		print "B$a[2]\t$a[0]\n";
	}
	close I;
}
