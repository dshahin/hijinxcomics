#!/usr/bin/perl
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);
use strict;
use HTML::Template;
use Net::Amazon;
#use Cache::File;

require("./config.pl");
my $template = HTML::Template->new(filename => 'templates/newcomics.tmpl.html');

my %invoice_codes;
my %previews;
open (INVOICE, "data/invoice.txt") || die "can not open data/invoice.txt";
while(<INVOICE>){
	my ($qty, $code,$desc,$ret,$unit,$inv_amt,
		$cat, $type, $foo, $bar,$upc,$isbn,$boo) = split /,/;
	$code =~ s/\"//g;
	$code =~ s/\s$//g;
	$code =~ s/\D$//;
	$isbn =~ s/\"//g;
	#if ($isbn <= 1){$isbn=1};
	$invoice_codes{$code} = $isbn;
}

#my $cache = Cache::File->new(
	#cache_root => '/tmp/hijinxcache',
	#default_expires => '7 days');

close INVOICE;
open (PREVIEWS, "data/master_previews.txt") || die "can not open data/master_previews.txt";
my @new_comics;
while (<PREVIEWS>){
	my ($code, $title, $price, $desc) = split /\t/;
	$title =~ s/\"//g;
	$code =~ s/\"//g;
        $code =~ s/\s$//g;
	foreach my $i_code (keys %invoice_codes){
		if ($code eq $i_code){
			my $img_url;
			if ($invoice_codes{$i_code} > 1){
				my $ua = Net::Amazon->new(token => 'D2DF0COTRJFEACa',);
					#cache => $cache) ;
				my $response = $ua->search(asin => $invoice_codes{$i_code});
				for ($response->properties){
					 $img_url = $_->ImageUrlMedium();
				}
				#print $img_url . "\n";
			}else{ $img_url = "/images/spacer.gif"}
			$previews{$code} = "$title\t$price\n$desc";
			my %new_comic;
			$new_comic{'TITLE'} = $title;
			$new_comic{'PRICE'} = $price;
			$new_comic{'DESC'} = $desc;
			$new_comic{'CODE'} = $code;
			#	print "template $title $img_url" . "\n";
			$new_comic{'IMG'} = $img_url;
			push (@new_comics, \%new_comic);
			#print "$code\n$title\n$desc";
		}
	}

}
close PREVIEWS;
sub bytitle {
	$a->{'TITLE'} cmp $b->{'TITLE'};
}

my @sorted_comics = sort bytitle @new_comics;

$template->param(THIS_WEEK_COMICS => \@sorted_comics);
open (NEWCOMICS, ">html/newcomics.html");
print NEWCOMICS $template->output;
#print "all done!\n";
