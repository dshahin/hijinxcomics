#!/usr/bin/perl
require("./config.pl");
print STDERR "enter current data invoice url:";
my $url = <STDIN>;
my @invoice = `wget -q --http-user=$DIAMOND_ID --http-passwd=$DIAMOND_PASS "$url" -O -`;
my $length = scalar(@invoice);
die "no data found. check url:\n$url\n" if $length == 0;
print "got it\n";
open (INVOICE, ">data/invoice.txt")|| die ("can't open data/invoice.txt:$!");
foreach(@invoice){
	if($_ =~ /^\d/){
		print INVOICE $_;
	}
}
