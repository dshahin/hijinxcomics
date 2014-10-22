#!/usr/bin/perl
use strict;
use HTML::Template;

require("./config.pl");
my $template = HTML::Template->new(filename => 'templates/newcomicscart.tmpl.html');

my %invoice_codes;
my %previews;
open (INVOICE, "data/invoice.txt") || die "can not open data/invoice.txt";
while(<INVOICE>){
	my ($qty, $code) = split /,/;
	$code =~ s/\"//g;
	$code =~ s/\s$//g;
	$code =~ s/\D$//;
	$invoice_codes{$code} = 1;
}
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
			$previews{$code} = "$title\t$price\n$desc";
			my %new_comic;
			$new_comic{'TITLE'} = $title;
			$new_comic{'PRICE'} = $price;
			$new_comic{'DESC'} = $desc;
			$new_comic{'CODE'} = $code;
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
open (NEWCOMICS, ">html/newcomicscart.html");
print NEWCOMICS $template->output;
