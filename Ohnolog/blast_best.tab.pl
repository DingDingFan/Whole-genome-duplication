#!/usr/bin/perl
use strict;
die "Usage: 	fafile  blastresult of  m8
	use the fafile to get the sequence length ,
	then have a compare to blast result,filter identity >50% 
	and lenght >50%\n"



unless @ARGV ;


&filter_blast($ARGV[0]);
##########################################################
#
########################################################
sub filter_blast{
	my %hit;
	open I,shift @_;
	while(<I>){
#		s/_\d+//;
		my ($g1,$score,$function)=(split /\t+/)[0,11,15];
#		my ($g1,$score,$function)=(split /\t+/)[0,12,15];
		next if /#Query_id/;
#		next if $g1 eq $g2;
#		next if $function =~/hypothe|uncharacterized|CG\d+|G\w\d+|^AAEL/;
		push @{$hit{$g1}}, [$_,$score,$function];
	        #	print;
	}
	close I;


	foreach my $g1 (keys %hit) {
		@{$hit{$g1}} = sort {$b->[-2] <=> $a->[-2]} @{$hit{$g1}};
		foreach my $p (@{$hit{$g1}}) {
			print "@$p[0]" ;
			last;
		}
	}
}
sub index{
	my %hash;
		my @temp=&openfile(shift @_);
		foreach(@temp){
			my ($id )=(split /\s+/,)[0,-2,-1];
			$hash{$id}=1;
		}
	return %hash;
}
sub seqlen{
	my (%seqhash)=@_;
	my %len;
	foreach (keys %seqhash) {
		$seqhash{$_}=~ s/\n+//g;
		
		$len{$_} = length $seqhash{$_};  
	}
	return %len;
}
sub seqhash{
	my (@fafile)=@_;
	my %seqhash;
	my $temp;
	foreach(@fafile){
		if (m/>(\S+)/){$temp=$1; next;}  
		$seqhash{$temp}.=$_;
	}
	return %seqhash;
}
sub openfile{
	my ($filename)=@_;
	open LISTFILE ,$filename or die "you can not open $filename\n";
	my @seq=<LISTFILE>;
	close LISTFILE ;
	return @seq;
}
