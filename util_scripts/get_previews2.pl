#!/usr/bin/perl


require("./config.pl");
my $txt = "txt";
my @months = qw(jan feb mar apr may jun jul aug sep oct nov dec);
my @years = qw(01 02 03 04 05 06);
my %monums = qw(jan 01 feb 02 mar 03 apr 04 may 05 jun 06 jul 07 aug 08 sep 09 oct 10 nov 11 dec 12);
my $base_url = "https://retailer.diamondcomics.com/main/monthly/archive/20";
open (OUTFILE, ">data/master_previews.txt");
foreach my $month (@months){
 foreach my $year (@years){
	 my $mo = $monums{$month};
 	 my $yeartxt = "$year$txt";
 	 my $url = "$base_url$yeartxt/$mo$yeartxt/$month$year\_previews.db.TXT";
 	 my @previews = `wget -q --http-user=$DIAMOND_ID --http-passwd=$DIAMOND_PASS "$url" -O -`;
 	my $length = scalar(@previews);
 	warn "no data found. check url:\n$url\n" if $length == 0;
 	foreach(@previews){
  		print OUTFILE $_;
	}
	print STDERR $url, "\n";
 }
}
