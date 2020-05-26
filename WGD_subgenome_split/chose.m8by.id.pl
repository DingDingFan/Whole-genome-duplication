#!/usr/bin/perl 
use strict;
die "Usage: < m8 all.idm8" unless @ARGV;
my %hash=&index;

#############################################################################
open I,"$ARGV[0]";
while(<I>){
	my ($id,$gene)=(split /\s+/,$_)[0,1];
	if(exists $hash{$id} and exists $hash{$gene}){
		next;
	}else{print;}
}
close I;
##############################################################################
sub index{
	my @go = &openfile($ARGV[1]);
	my %hash;
	foreach(@go){
		chomp;
		my @a=(split /\s+/,);
		$hash{$a[0]}++; # if $p > 0.5;
	}
	return %hash;
}
sub openfile{
	my ($filename)=@_;
	open LISTFILE ,$filename or die "you can not open $filename\n";
	my @seq=<LISTFILE>;
	close LISTFILE ;
	return @seq;
}
