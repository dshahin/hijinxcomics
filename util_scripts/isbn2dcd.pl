#!/usr/bin/perl
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);

#require("./config.pl");
our $DIAMOND_ID = "";
our $DIAMOND_PASS = "";
my $isbn = shift;
#my $isbn = <STDIN>;
chomp $isbn;
my $url = "https://retailer.diamondcomics.com/main/data_tools/StockLookup.asp?QueryItem=" . $isbn;
my @page = `wget -q --http-user=$DIAMOND_ID --http-passwd=$DIAMOND_PASS "$url" -O -`;
my @lines = grep (/OpenShoppingListWindow\(\'/, @page);
my $line = $lines[0];
chomp $line;
$line =~ s/.*?\(\'(\w\w\w\w\w\w\w\w\w).*?$\'/$1/;
$line =~ s/(.*?)\).*/$1/;
print $line;
#print @page;
