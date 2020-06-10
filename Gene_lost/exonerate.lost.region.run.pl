#!/usr/bin/perl 
use strict;
use FindBin qw($Bin);
die "Usage: <pep genome.fas lost.bed >!\n"
unless @ARGV ;
my ($Fpep,$Ffas,$Flost)=@ARGV;
######################################
my %pep;
&index(\%pep,$Fpep);

`bedtools  getfasta   -fi $Ffas -bed $Flost > $Flost.fas `;

my %pair;
open I ,"$Flost";
while(<I>){
	next if /\#/;
	chomp;
	my @a=split /\t/;	
	$pair{$a[3]}="$a[0]:$a[1]-$a[2]";
}
close I;


my %fas;
&index(\%fas,"$Flost.fas");

my $i=0;
mkdir "exonout";
foreach my $g1 (keys %pair){
	chomp;
	my $g2=$pair{$g1};
	open O ,">exonout/$g1.pep.fasta";	
	print O ">$g1.pep $g1\n$pep{$g1}\n";
	close O;
	open O ,">exonout/$g1.gene.fasta";	
	print O ">$g2 $g2\n$fas{$g2}\n";
	close O;
	#`exonerate  --model protein2genome   exonout/$g1.pep.fasta exonout/$g1.gene.fasta   --showtargetgff  > exonout/$g1.exon ;` 
	` exonerate  --model protein2genome   exonout/$g1.pep.fasta exonout/$g1.gene.fasta   --showtargetgff  > exonout/$g1.exon ;  makeblastdb  -input_type  fasta  -dbtype nucl -in exonout/$g1.gene.fasta  ;  tblastn  -db exonout/$g1.gene.fasta   -out exonout/$g1.tblastn  -evalue 1e-2  -num_threads 1  -query exonout/$g1.pep.fasta  -outfmt 6 `;
	#$i++;
	#exit if $i >3000;
}
##############################################################################
sub index{
	my $fas= shift @_;
	my ($in_file) = shift @_;
	if($in_file=~ /\.gz$/){
		open IN, "gzip -dc $in_file|";
	}else{
		open IN, $in_file;
	}
	$/ = ">";
	<IN>;
	while (<IN>) {
		/(\S+)/;
		my $id="$1";
		s/.+//;
		s/\s+|>//g;
		#$id=~ s/\-R\w+$//;
		#$id=~ s/\-\d+\-tr//;
		$id=~ s/_SINgra|_CARaur//;
		$$fas{$id}=$_;
	}
	$/ = "\n";
	close IN;
}
