#!/usr/bin/perl

while(<>){
	my @fields = split /,/;
	my $length = @fields;
	if ($length < 2){
		print $_;
	}elsif($length == 15){
		convert_to_16($_);
	}elsif($length == 16){
		print "16:$fields[1]\n";
		#convert_to_15($_);
	}
}

sub convert_to_16 {
	my @fields = split /,/;
	my $dcd = $fields[1];
	$dcd =~ s/\W//g; #strip non-word chars and space
 	my $discount = chop($dcd);
	print "15:$dcd  discount:$discount\n";
}
