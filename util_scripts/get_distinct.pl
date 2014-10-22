#!/usr/bin/perl 
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5/
		/home/dan/cpro.hijinxcomics.com/test);

use strict;
use DBI;

my $dbh = DBI->connect( "dbi:mysql:HIJINX01", "dan", "" ) || die "no connect:$!\n";
my $sth = $dbh->prepare("select distinct isbn, title, price, in_stock from books order by title") || die "can't prep 1:$!\n";
#my $sth2 = $dbh->prepare( "select count(isbn) from notes where isbn = ?") || warn "can't prep 2:$!" ;
$sth->execute();
while ( my $book = $sth->fetchrow_hashref ) {
	#$sth2->execute($book->{'isbn'}) || die "can't execute", $sth2->errstr;
	#my ($count) = $sth2->fetchrow_array;
	#if ($count == 0 && $book->{in_stock} > 1){
	if ( $book->{in_stock} > 0){
		print "\"".$book->{title}."\"" . "," . $book->{isbn} . "," . $book->{price} . "," .  $book->{in_stock} . "\n";
	}
}
