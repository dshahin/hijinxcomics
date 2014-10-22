#!/usr/bin/perl 
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5/
		/home/dan/cpro.hijinxcomics.com/test);

use strict;
use DBI;
use Net::Amazon;
use Business::ISBN qw(ean_to_isbn is_valid_checksum);

my $dbh = DBI->connect( "dbi:mysql:HIJINX01", "dan", "" ) || die "no connect:$!\n";
my $sth = $dbh->prepare("select distinct isbn from notes") || die "can't prep 1:$!\n";
my $sth2 = $dbh->prepare( "insert into books values(NULL,?,?,?,?,?,?,?,?,?)") || warn "can't prep 2:$!" ;
my $dcd;
my $title;
my ($price, $isbn, $upc, $info, $in_stock,$on_order);
my $min = 1;
$in_stock = 0;
$on_order= 0;
$sth->execute();
while ( my $book = $sth->fetchrow_hashref ) {
	my $isbn = $book->{'isbn'};
    		if ( is_valid_checksum($isbn) eq Business::ISBN::GOOD_ISBN ) {
			my $ua       = Net::Amazon->new( token => '1DSVSTQTDJQCGAC0KF02' );
                        my $response = $ua->search( asin       => $isbn );
                        if ($response->is_success()){
        			for ( $response->properties ) {
            			$title = $_->ProductName();
            			$price = $_->ListPrice();
            			#$info = $_->authors();
            			$price =~ s/\$//;
        			}
				print "$title $price\n";
				$sth2->execute($dcd,$title,$price,$isbn,$upc,$info,$min,$in_stock,$on_order) 
					|| warn "can't add new book" . $sth2->errstr;
			}
		}
}
