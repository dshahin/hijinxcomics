#!/usr/bin/perl
#
# usage: invoice2xml invoice.txt 
#
#


use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);
use XML::Simple;
my $inputfile = shift;
#open INPUT, $inputfile or die "can't open $inputfile :$!";
my %invoice;	
#while(<INPUT>){
	#@fields = split;
#}
$invoice{'foo'} = 'bar';
$invoice{'bar'} = 'foo';
my $xml = XMLout(\%invoice);
print $xml;

