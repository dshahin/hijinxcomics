#!/usr/bin/perl
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);

use Net::Amazon;
use DBI;

my $ua = Net::Amazon->new(token => '1DSVSTQTDJQCGAC0KF02',
							secret_key => 'eWIPQ1bscu/AhDQQ3QLCMCRnXah30QhmovqgZKbk');
                                        #cache => $cache) ;
 my $dbh = DBI->connect( "dbi:mysql:HIJINX01", "dan", "rliump" )
          || die "can't connect to HIJINX01:$!\n"  ;
my $sth = $dbh->prepare("select isbn, title, id from books where in_stock > 0 order by title");
my $sth2 = $dbh->prepare("insert into tags values(?, 'book', 'amazon_chk_09_28_08')");
$sth->execute;
while (my ($isbn, $title, $id) = $sth->fetchrow_array){

        my $response = $ua->search(asin => $isbn);
	if($response->is_success()){
		#print $response->as_string(), "\n";
		for ($response->properties){
		 	my $ProductName = $_->ProductName();
		 	my $ListPrice = $_->ListPrice();
		 	$ListPrice =~ s/\$//;
		 	my $UsedPrice = $_->UsedPrice();
		 	$UsedPrice =~ s/\$//;
			if (($UsedPrice - $ListPrice) > 1  && $ListPrice > 0){
				my $percentage = $ListPrice / $UsedPrice;
				my $diff = $UsedPrice - $ListPrice;
				print "\n$ProductName\nisbn:$isbn\nList Price:$ListPrice  Used Price:$UsedPrice\nDIFFERENCE:$diff\n\n"; 
				$sth2->execute($id) || die "can't execute" . $sth2->errstr;
			}else{
				#print "$ProductName\nUsed:$UsedPrice\nNew:$ListPrice\n";
			};
		}
	}else{
		print "Error: ", $response->message(), " $title\n";
	}
	
}
