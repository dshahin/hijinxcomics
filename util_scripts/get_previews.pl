#!/usr/bin/perl
require("./config.pl");
#use strict;
#print "what is your diamond user id? (DCD):";
#my $id = <stdin>;
#print "what is your diamond user id? (DCD):";
#my $passwd = <stdin>;
#chomp($id, $passwd);

my @months = qw(jan feb mar apr may jun jul aug sep oct nov dec);
my @years = qw( 03 04);
my $base_url = "https://retailer.diamondcomics.com/main/monthly/previewsdb/";
open (OUTFILE, ">data/master_previews.txt");

foreach my $month (@months){
	foreach my $year (@years){
		my $url = "$base_url$month$year\_previews.TXT";
		my @previews = `wget -q --http-user=$DIAMOND_ID --http-passwd=$DIAMOND_PASS "$url" -O -`;
		my $length = scalar(@previews);
		warn "no data found. check url:\n$url\n" if $length == 0;
		foreach(@previews){
			print STDERR $url, "\n";
			print OUTFILE $_;
		}
		
	}
}


