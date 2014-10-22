#!/usr/bin/perl

use DBI;
my $isbn = shift;
my $dbh = DBI->connect( "dbi:mysql:HIJINX01",  "dan", "");
my $sth = $dbh->prepare("select distinct customer_id from notes where isbn = ?" );
my $sth2 = $dbh->prepare("select distinct isbn from notes where notes.customer_id = ? and isbn > 0");
my $sth3 = $dbh->prepare("select title from books where isbn = ?");

$sth->execute($isbn) || die "can't do it" ;
my %books;
while(my $customer = $sth->fetchrow_hashref){
	$sth2->execute($customer->{"customer_id"})|| die "can't get last checkin: $!";
	while(my $book = $sth2->fetchrow_hashref){
		$books{$book->{"isbn"}}++ ;
	}
}


sub hashvalsort{
	$books{$b} <=> $books{$a};
}
$counter = 0;
foreach $key (sort hashvalsort (keys (%books))){
	unless ($key eq $isbn || $books{$key} == 1 ){
		$sth3->execute($key) || die "can't do it" ;
		my $title;
		while(my $sugg = $sth3->fetchrow_hashref){
			$title = $sugg->{'title'};
		}
		if ($counter < 3){
			print "$books{$key} $title $key\n";
			$counter++;
		}else{
			last;
		}
	}
}
