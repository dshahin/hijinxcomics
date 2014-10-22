#!/usr/bin/perl
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);

use XML::RSS;
require("./config.pl");
my $arg = shift;
my $quiet = 0;
if ($arg eq "-q"){ $quiet = 1};

#my $this_week_url = "https://retailer.diamondcomics.com/main/current/shipall.txt";
#my $next_week_url = "https://retailer.diamondcomics.com/main/current/shipall.txt";
#my @this_week = `wget -q --http-user=$DIAMOND_ID --http-passwd=$DIAMOND_PASS "$this_week_url" -O -`;
open (INVOICE, "data/invoice.txt") || die "can't open invoice";
my @this_week = <INVOICE>;
my $rss = new XML::RSS (version => '1.0');
$rss->channel(
	title => "Hijinx Comics: New this week",
	#link => "http://www.hijinxcomics.com",
	description => "Comics and Books expected in stock from Diamond",
	dc => {
			date => `date`,
			subject => "shipping from Diamond Comics",
			creator => 'dan@hijinxcomics.com',
			publisher => 'dan@hijinxcomics.com',
			rights => 'Copyright 2003, Diamond Comic Distributers',
			language => 'en-us',
		},
	syn => {
			updatePeriod     => "weekly",
			updateFrequency  => "1",
			updateBase       => "1901-01-01T00:00+00:00",
		},


);

foreach my $item (@this_week){
	if ($item =~ /#/ || $item =~ /TP/ || $item =~ /HC/){
	$item =~ s/\"//g;
	my ($qty, $item_code, $title, $price, $publisher) = split /,/, $item;
	chop $item_code;
	chop $item_code;
	unless ($quiet == 1){ print "$item_code  $title\n"};
	open (PREVIEWS, "data/master_previews.txt") || die "can not open data/master_previews.txt";
	while(<PREVIEWS>){
		#print "foo:$code\n";
		s/\"//g;
		my ($pcode, $ptitle, $pprice, $pdesc) = split /\t/;
		$title =~ s/\(.*?\)//g;
		#$pcode =! s/\"//g;#
		#print "pcode: $pcode\n";
		if ($item_code eq $pcode){
			$rss->add_item (title=> $title, description => "$pdesc", link => "http://www.hijinxcomics.com/newcomics.html#$item_code" );
			unless ($quiet == 1){
				print "found $title\n $pdesc $pprice\n";
			}
			last;
		}else{
			#print "can't find $item_code , $pcode\n";
		}
	}	

	close PREVIEWS;
	}
}
$rss{output} = '1.0';
open (THIS_WEEK, ">/home/dan/www.hijinxcomics.com/html/newthisweek.rss") || die "can not open data/thisweek.rss:$!\n";
print THIS_WEEK $rss->as_string;
close THIS_WEEK;
