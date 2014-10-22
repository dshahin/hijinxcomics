#!/usr/bin/perl

use HTML::Template;
use DBI;
my $dbh = DBI->connect( "dbi:mysql:hijinx@gal",  "hijinx", "passwerd") || die "no connect:$!\n" ;
my $sth = $dbh->prepare("select id from titles where name = ?" ) || die "no select:$!\n";
my $template = HTML::Template->new(filename => 'templates/order_import.tmpl.html');
my @comics;
my %vendors;
open (VENDORS, "data/DBA_vendor.csv")|| die "can't open vendors:$!";
while(<VENDORS>){
	#print "$_\n";
	my ($vcode, $vname) = split /,/;
	$vendors{$vcode} = $vname;
}
open (ORDER_FORM, "data/latest_order_form.txt")|| die "can't open vendors:$!";
while(<>){
#print "foo\n";
my %line;
my ($batchno, $itemno,$discountcode, $itemdescription, $category,
$vendor, $genre, $brand, $shipdate, $oicdate, $upc, $pagenumber,
$adult, $offeredagain, $caution1, $caution2, $caution3, $caution4,
$mature, $resolicited, $marvelfullline, $price, $srp, $cost, $issue,
$noteprice, $parentitem, $maxissue, $stockcode, $seriescode) =
print "$itemdescription \#$issue\n";
split /\t/;
if ($category == 1 && $parentitem eq " "){
	print "$itemdescription #$issue $price\n";
	$line{"itemdescription"} = $itemdescription;
	$line{"issue"} = $issue;
	$line{"price"} =  $price;
	$line{"vendorname"} = $vendors{$vendor};
	open (PREVIEWS, "data/latest_previews.txt")|| die "can't open previews:$!";
	while (<PREVIEWS>){
		s/\"//g;
		my ($dcd, $title, $price, $desc) = split /\t/;
		if ($dcd eq $itemno){
			$line{"desc"} = $desc;
			print "$dcd  -> $itemno\n$desc\n\n";
			last;
		}
	}
	close PREVIEWS;
	my $status = $sth->execute($itemdescription);
	my $id = 0;
	if ($status == 1) {
		$id =  $sth->fetchrow_array, "\n";
		$line{"id"} = $id;
	}
	push (@comics, \%line);
	
}
}
$template->param(COMICS => \@comics);
open (HTML, ">order.html") || die "can't open order.html: $!";
print HTML $template->output;
