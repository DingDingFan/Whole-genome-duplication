package Lastz;
use strict ;
use List::Util qw[min max];
#####################################
sub title{
	my ($wid,$height,$grid)=@_;
	$wid= $wid>0?$wid:1000;
	$height= $height>0?$height:800;
	$wid+=200;
	
	my $title='';
	$title.= '<?xml version="1.0" standalone="no"?>'. "\n";
	$title.= '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">'. "\n";
	$title.= '<svg width='."\"$wid\" ". 'height='."\"$height\" ".'version="1.1" xmlns="http://www.w3.org/2000/svg">'. "\n";
	my $x=100;
	my $y=150;
	for(my $i =1;$i<21;$i++){
		$x+=50;
		my $y1=$y;
		my $y2=1000;
		$title.= "<line x1=\"$x\" y1=\"$y1\" x2=\"$x\" y2=\"$y2\" stroke=\"#DCDCDC\" stroke-dasharray=\"10 10\" stroke-width=\"0.5\"/>"."\n" if $grid;
	}
	return $title;
	print "Title:\tOk\n";
}
#####################################################
sub readTab{
	my ($hash,$file)=@_;
	open I ,"$file";
	my (@s1,@s2,@t1,@t2);
	while(<I>){
		next if /\#/;
		my @a=split /\s+/;
		push @{ $$hash{$a[0]}{$a[1]} } ,[@a];
	}
	close I;
	print "ReadTab:\tOK\n";
}
sub heatmap{
	#http://colorbrewer2.org/#type=sequential&scheme=YlOrBr&n=6
	my $alnID=shift @_;
#	my %color=('50','#ffffd4','60','#fee391','70','#fec44f','80','#fe9929','90','#d95f0e','100','#993404');
#	my %color=('70','#ffffd4','80','#fee391','85','#fec44f','90','#fe9929','95','#d95f0e','99','#993404');
	#my %color=('70','#3288BD','80','#66C2A5','85','#FEE08B','90','#FDAE61','95','#F46D43','99','#D53E4F');
	my %color=('70','#999999','80','#458B74','85','#377EB8','90','#F781BF','95','#FF7F00','99','#E41A1C');
	my %name="";
	my $flag=1;
	my @ids=sort {$b <=> $a} keys %color;

	for(my $i=0;$i< scalar @ids; $i++){
		my $name='';
		if($i==0){
			$name="&gt;=$ids[$i]";
		}elsif($ids[$i] == $ids[-1] ){
			$name="&lt;$ids[$i]";
		}else{
			$name="&lt;$ids[$i]&gt;=$ids[$i+1]";
		}
		$name{ $ids[$i] } = $name;
		if($flag){
			if($alnID >= $ids[$i]){
				$flag--;
				$alnID=$ids[$i];
			}elsif($alnID <$ids[-1]){
				$flag--;	
				$alnID=$ids[-1];
			}
		}
	}
	my $legend='';
	my $cy=230;
	foreach my $id (sort keys %color){
		my $col=$color{$id};
		my $te=$name{$id};
		$legend.= "<rect y=\"$cy\" x=\"500\" width=\"20\" height=\"10\" style=\"fill:$col;stroke:$col;stroke-width:0;\"/>\n";  
		my $ty= $cy +10  ;	
		$legend.= "<text y=\"$ty\" x=\"525\" font-size=\"10\" fill=\"black\">$te</text>"."\n"; 
		$cy-=12;
	}
	return ($color{$alnID},$legend);
}
sub readGFF{
	my ($hash,$file)=@_;
	open I ,"$file";
	while(<I>){
		next if /^\#/;
		chomp;
		my @a=split /\t/;
		$a[8]=~ /=([^;]+);/;			
		my $id=$1;
		push @{ $$hash{$id} } , [@a]; 
	}
	close I;
	print "Readgff\t$file\n";
}
###################################################################
sub axis{
	my ($y,$s,$t,$pix,$fold,$up)=@_;
	 $fold =10 unless $fold;
	my $len=($t-$s+1)/$fold;
	$len=~ s/\.\d+//;
	print "axis:$len\n";
	my @range=qw(1000000 500000 200000 100000 50000 20000 10000 1000);
	foreach(@range){
		if( $len > $_*0.8){ $len = $_; last;}
	}
	my $n=0;
	my $svg='';
	for(my $i=$s;$i<$t;$i=$i+$len){
		my $x=100+ ($i-$s)*$pix;
		$n++;
		my $yt=$y;
		if($n % 2 == 0){
			$yt= $up ? $y-15 :$y+15; ;
		}else{
			$yt= $up ? $y-18 :$y+18; ;
		}
		my $text = sprintf("%.1f", $i/1000); 
		my $tx=$x-5;
		$svg.= "<text x=\"$x\" y=\"$yt\" fill=\"black\" font-family=\"Arial\" font-size=\"8\">".$text."k</text>"."\n" ;
		my $y1=$y; my $y2= $up ? $y1-8 :$y1+8;
		$svg.= "<line x1=\"$x\" y1=\"$y1\" x2=\"$x\" y2=\"$y2\" stroke=\"black\" stroke-width=\"1\"/>"."\n";

	}
	return $svg;
}
sub gene{
	my ($chr,$y,$s,$t,$pix,$gff,$title)=@_;
	my $svg='';
	$svg.="<text x=\"10\" y=\"$y\" fill=\"black\" font-family=\"Arial\" font-size=\"10\">"."$title"."</text>"."\n" ;
	 my $n=0;
	my $gy=$y;
	foreach my $id(keys %{$gff}){	
		my @color=qw(black);#8A2BE2 black
		my $flag=0;
		my $gy=$y-$n%2*10;
		foreach my $L(@{$$gff{$id}}){
			my @a= @$L;
			my $strand=$a[6];
			my $geneid=(split /\=/,$a[-1],2)[1];
			if($a[0] eq $chr  and ($a[3]>= $s) and ($a[4]<= $t) ){
				my $color=$color[ $n%2 ];
				my $x1=100 + ($a[3]-$s+1)*$pix; 
				my $x2=100 + ($a[4]-$s+1)*$pix; 
#				print join "\t",@a,"$x1,$x2,$id,$color\n";
				if($a[2] eq 'mRNA'){
					$svg.= "<line x1=\"$x1\" y1=\"$gy\" x2=\"$x2\" y2=\"$gy\" stroke=\"blue\" stroke-width=\"3\"/>"."\n";
					my $tx=$x1+($x2-$x1+1)/5;;
					my $ty=$gy-$n%2*5;
					print "$n:$ty:\n";
					$svg.="<text x=\"$tx\" y=\"$ty\" fill=\"black\" font-family=\"Arial\" font-size=\"8\">"."$geneid"."</text>"."\n" ;
					my $len=($x2-$x1)/3;
					$svg.= &strand($x1,$x2,$gy,$strand,$pix);
					$flag++;
				}elsif($a[2] eq 'CDS'  and $flag){
					my $win=($x2-$x1)/10 > 10 ? 10 : ($x2-$x1)/10 ;
					my ($x1,$y1,$x2,$y2,$x3,$y3,$x4,$y4)=($x1,$y,$x1+$win,$y-6,$x1+$win,$y-3,$x2,$y-3);
					my ($x5,$y5,$x6,$y6,$x7,$y7)=($x2,$y+3,$x1+$win,$y+3,$x1+$win,$y+6);
					$svg.="<line x1=\"$x1\" y1=\"$gy\" x2=\"$x4\" y2=\"$gy\" stroke=\"red\" stroke-width=\"9\"/>"."\n"
#					print FIGOUT &plot_triangle($x1,$x2,$y,$strand);
				}
			}
		}
		$n++;
	}
	return $svg;
}
sub repeat{
	my ($chr,$y,$s,$t,$pix,$gff,$name)=@_;
	my $svg='';
	$svg.="<text x=\"10\" y=\"$y\" fill=\"black\" font-family=\"Arial\" font-size=\"10\">"."$name"."</text>"."\n" ;
	my %color=( 'DNA' => "blue", "LINE" => "red" , "LTR" => "purple" ,"Others"=> 'black');#8A2BE2 black
	my $n=0;
	foreach my $id(keys %{$gff}){	
		foreach my $L(@{$$gff{$id}}){
			my @a= @$L;
			my $strand=$a[6];
			if($a[0] eq $chr  and ($a[3]>= $s-1000) and ($a[4]<= $t +1000) ){
				$a[-1] =~ /Class=([^;]+);/; 
				my $class="$1"; $class=~ s/\/.+//;
				my $color= exists $color{$class} ?  $color{$class}   : 'black' ;
				#print join "\t",@a;
				#print "$class\t$color\t$id\n";
				#print "$class\t$color{$class}\n";
				my $x1=100 + ($a[3]-$s+1)*$pix; 
				my $x2=100 + ($a[4]-$s+1)*$pix; 
				my $ly=$y-$n%2*2;
				my $tx=$x1; my $ty=$ly;
				$svg.="<line x1=\"$x1\" y1=\"$ly\" x2=\"$x2\" y2=\"$ly\" stroke=\"$color\" stroke-width=\"6\"/>"."\n" ;
				
				$n++;
			}
		}
	}
	return $svg;
}
sub nucdiff{
	my ($chr,$y,$s,$t,$pix,$gff,$name,$tag)=@_;
	my $svg='';
	$svg.="<text x=\"10\" y=\"$y\" fill=\"black\" font-family=\"Arial\" font-size=\"10\">"."$name"."</text>"."\n" ;
	my $n=0;
	foreach my $id(keys %{$gff}){	
		foreach my $L(@{$$gff{$id}}){
			my @a= @$L;
			if($a[0] eq $chr  and ($a[3]>= $s-1000) and ($a[4]<= $t +1000) ){
				$a[-1] =~ /Name=([^;]+);/;
				my $class="$1"; 
				my $color = $a[-1]=~ /color=(\#\S+)/ ?  $1   : 'black' ;
				print "$class\t$color\n";
				my $x1=100 + ($a[3]-$s+1)*$pix; 
				my $x2=100 + ($a[4]-$s+1)*$pix; 
				my $ly=$y;
				my $ty=$ly;
				if($tag eq 'up')
				{	
					$ly-=$n%2*20;
					$ty=$ly-4;
				}else{
					$ly+=$n%2*20;
					$ty=$ly+4;
				}
				
				my $tx=$x1;
				$svg.="<text x=\"$tx\" y=\"$ty\" fill=\"black\" font-family=\"Arial\" font-size=\"3\">"."$id"."</text>"."\n";
				$svg.="<line x1=\"$x1\" y1=\"$ly\" x2=\"$x2\" y2=\"$ly\" stroke=\"$color\" stroke-width=\"5\"/>"."\n";
				$n++;
			}
		}
	}
	return $svg;
}
sub Legend{
	my %color=( 'DNA' => "blue", "LINE" => "red" , "LTR" => "purple" ,"Others"=> 'black');#8A2BE2 black
	my $cy=230;
	my $svg='';
	foreach my $te (sort keys %color){
		my $col=$color{$te};
		$svg.=  "<rect y=\"$cy\" x=\"200\" width=\"30\" height=\"10\" style=\"fill:$col;stroke:$col;stroke-width:0;\"/>"."\n";  
		my $ty=$cy+10;
		$svg.=  "<text y=\"$ty\" x=\"233\" font-size=\"12\" fill=\"black\">$te</text>". "\n"; 
		$cy -=12;
	}
	return $svg;
}
######################################################################
sub strand{
		my ($start,$end,$y,$strand,$pix)= @_;
		my $color= "#000000";
		my $height=5.5;
		my ($x1,$x2,$y1,$y2);
		my $len   = $end -$start+1;
		my $angle = $len/10 > 20 ? 20  : $len/20 ;
		print "strand:step:$angle\n";
		$y1=$y+$height;
		$y2=$y-$height;
		my $svg = "";
		my $step=50;
		for(my $i=0;$i<$len/$step;$i++){
			my ($s)=($start+$i*$step);	
			$x1=$s -$angle  if $strand eq '-';
			$x1=$s+ $angle if $strand eq '+';
			$x2=$s;
			$svg.="<polyline points=\"$x2,$y1 $x1,$y $x2,$y2\" style=\"fill:none;stroke:black;stroke-width:1\"/>\n" 
		}
		return $svg;
}
sub index{
		open I,shift @_;		
		my %hash;
		while(<I>){
			my @a=split ;
			next unless $a[0];
			if($a[1]){
				$a[0]=lc $a[0];
				$hash{$a[0]}=$a[1];		
			}else{
				$a[0]=lc $a[0];
				$hash{$a[0]}='#6666FF';		
			}
		}
		close I;
		return %hash;
}
sub FPKM{

}
;1
