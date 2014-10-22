#!/usr/bin/perl

use DBI;
use Net::Amazon;


my $ua = Net::Amazon->new(token => 'D2DF0COTRJFEACa');

my $dbh = DBI->connect( "dbi:mysql:hijinx",  "hijinx", "passwerd") || die "no connect:$!\n" ;
open (INVOICE, "data/invoice.txt") or die "can't open data/invoice.txt:$!";
my $sth = $dbh->prepare("insert into books values(?,?,?,?,?,?,?,?,?,?,?,?,?)" );

while(<INVOICE>){
	s/"//g;
	my ($URL1, $URL2, $URL3);
	#my($diamond,$discount,$description,$price,$ISBN,$category) = split /,/;
	my($qty,$diamond,$description,$price,$unit,$unit2,$cat,$type,$foo,$bar,$upc, $ISBN) = split /,/;
	chop $diamond ;
	$discount = chop $diamond ;
	#print "$ISBN $diamond $cat\n";
	my $response = $ua->search(asin => $ISBN);
	if($response->is_success()) {
		for ($response->properties){
			$URL1 = $_->ImageUrlSmall();	
			$URL2 = $_->ImageUrlMedium();	
			$URL3 = $_->ImageUrlLarge();	
			#print "$description\n$URL1\n$URL2\n$URL3\n\n";
		}
	}else{
		$URL1 = "http://hijinxcomics.com/images/spacer.gif";
		$URL2 = "http://hijinxcomics.com/images/spacer.gif";
		$URL3 = "http://hijinxcomics.com/images/spacer.gif";
	}	
	open (PREVIEWS, "data/master_previews.txt") || die "can not open master_previews.txt";
	my $DESC = "n/a";
	 while (<PREVIEWS>){	
		s/\"//g;
		my ($code, $title, $price, $desc) = split /\t/;
		if ($diamond eq $code){
			$DESC = $desc;
			#print "desc:$DESC\n";
			last;
		}
	}
	close PREVIEWS;
	if ($cat == 3 || $cat == 4){
		$sth->execute(NULL,$diamond,$discount,$description,$price,$ISBN,$upc,$upc,$cat,$URL1,$URL2,$URL3,$DESC) || warn "couldn't execute for $title: $!\n";
		print "add $diamond $discount $description $ISBN $category\n$DESC\nupc:$upc\n\n";
	}else{
		#print "not adding $diamond $description $ISBN $category\n";
	}
}


