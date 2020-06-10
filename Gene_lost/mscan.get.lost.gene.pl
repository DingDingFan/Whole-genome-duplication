#!/usr/bin/perl 
use strict;
#use FindBin qw($Bin/fdd_package/);
die "Usage: <syteny,col,prefix>!\n"
unless @ARGV ;
my ($list_file,$source,$prefix)=@ARGV;
######################################
my %syn;
my %chr;
&syteny(\%syn,$list_file,\%chr);
#my %r1r2;
#&r1r2(\%r1r2,$Fr1r2);
my %col;
open I,"$source";
while(<I>){
	if(/^#/){ next;};
	s/^\s+//;
	s/\s+/\t/g;
	chomp;
	my @a=split /\t/;
	my ($g1,$g2)=@a[2,3];
	$g1=~ s/_SINgra|_CARaur//;
	$g2=~ s/_SINgra|_CARaur//;
	$col{$g1}++;
	$col{$g2}++;
}
close I;
open I,"$source";
open O,">$prefix.tmp.syn";
while(<I>){
	if(/^#/){ next;};
	s/^\s+//;
	s/\s+/\t/g;
	chomp;
	my @a=split /\t/;
	my ($g1,$g2)=@a[2,3];
	$g1=~ s/_SINgra|_CARaur//;
	$g2=~ s/_SINgra|_CARaur//;
	my $syn1= exists $syn{$g1} ? join "\t",@{$syn{$g1}} : "\tNA"x6 ;
	my $syn2= exists $syn{$g2} ? join "\t",@{$syn{$g2}} : "\tNA"x6 ;
	print O  "$_\t$col{$g1}\t$col{$g2}\t$syn1\t$syn2\n";
}
close I;
close O;
#########
my %block;
open I ,"$prefix.tmp.syn";
while(<I>){
	chomp;
        my @a=split /\t/;
	push @{$block{$a[0]}} , [@a] ;
}
close I;
open O ,">$prefix.lost.bed\n";
my $st;
foreach my $bl(keys %block){
	my @a=@{$block{$bl}};
	my $n=scalar @a;	
#	print "$bl\t$n\n";
	for(my $i=0;$i<$n;$i++){
		my @b1=@{$a[$i]};
	#	print "$b1[1]\t$b1[15]\n";
		last if $b1[9] eq $b1[15];
		for(my $j=$i;$j<$n;$j++){
			my @b2=@{$a[$j]};
			my $m1= abs $b1[10] - $b2[10];
			my $m2= abs $b1[16] - $b2[16];
			my $flag=0;
			my $bed='';
			if($m1  > 1 and $m1 <4  and $m2 ==1 ){
				my ($s,$t)=sort {$a <=> $b} ($b1[10], $b2[10]);
				for(my $x=$s+1;$x<$t;$x++){
					my $tag= $x;
					my $lost=@{$chr{$b1[9]}{$tag}}[0];
					next if exists $col{$lost};
					print "<$lost\t$x\n";
					$flag++;
					$bed .=  "<$x\t$b1[2]\t$lost\t$b1[15]\t$b1[18]\t$b2[17]\n" if $b1[16] < $b2[16]	;
					$bed .= "<$x\t$b1[2]\t$lost\t$b1[15]\t$b2[18]\t$b1[17]\n" if $b1[16] >  $b2[16]	;
					my ($s1,$t1,$s2,$t2);
					if($b1[10] < $b2[10]){
							
					}
				}
							
			}elsif($m2 > 1 and $m2 <4  and $m1 ==1 ){
				my ($s,$t)=sort {$a <=> $b} ($b1[16], $b2[16]);
				for(my $x=$s+1;$x<$t;$x++){
					my $tag= $x;
					my $lost=@{$chr{$b1[15]}{$tag}}[0];
					next if exists $col{$lost};
					print "<$lost\t$x\n";
					$flag++;
					$bed .=  ">$x\t$b1[2]\t$lost\t$b1[9]\t$b1[12]\t$b2[11]\n" if $b1[10] <  $b2[10];
					$bed .=  ">$x\t$b1[2]\t$lost\t$b1[9]\t$b2[12]\t$b1[11]\n" if $b1[10] >  $b2[10];
				}
			}	
			print O "##### $st\t$flag######\n" if $flag;
			print O "$bed" if $flag;
			if($flag){
				$st++ if $flag;
				my ($s1,$t1,$s2,$t2);
				if($b1[10] < $b2[10]){
					($s1,$t1)=($b1[11],$b2[12]);
				}else{
					($s1,$t1)=($b2[11],$b1[12]);
				}
				if($b1[16] < $b2[16]){
					($s2,$t2)=($b1[17],$b2[18]);
				}else{
					($s2,$t2)=($b2[17],$b1[18]);
				}
				print O "#>$b2[9]\t$s1\t$t2\t$b1[15]\t$s2\t$t2\n";
			}
		
		}
	}
}
close O;
##############################################################################
sub syteny{
	my ($hash,$file)=@_;
	open I,"$file";
	while(<I>){
		chomp;
		my @a=(split /\t/,);
		@{$$hash{ $a[0] }} = @a[0..5];
		@{$chr{$a[1]}{$a[2]}} = @a[0..5];
	}
	close I;
}
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
sub r1r2{
	my ($hash,$file)=@_;
	open I,"$file";
	while(<I>){
		chomp;
		my @a=(split /\t/,);
		@{$$hash{ $a[0] }} = ($a[6],$a[-1],$a[-2]);
	}
	close I;
}
	
