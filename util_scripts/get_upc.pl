#!/usr/bin/perl
require("./config.pl");
#use strict;
#print "what is your diamond user id? (DCD):";
#my $id = <stdin>;
#print "what is your diamond user id? (DCD):";
#my $passwd = <stdin>;
#chomp($id, $passwd);

my @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
my @years = qw(2 3 4);
my $base_url = "https://retailer.diamondcomics.com/main/pod2/";

open (OUTFILE, ">data/master_upc.txt");

foreach my $year (@years){
	foreach my $month (@months){
		my $url = "$base_url$month$year" . "UPC.CSV";
		my @previews = `wget -q --http-user=$DIAMOND_ID --http-passwd=$DIAMOND_PASS "$url" -O -`;
		my $length = scalar(@previews);
		warn "no data found. check url:\n$url\n" if $length == 0;
		print STDERR $url, "\n";
		foreach(@previews){
			print OUTFILE $_;
		}
		
	}
}


