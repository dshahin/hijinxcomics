#!/usr/bin/perl
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);

use Net::Amazon;
use DBI;

my $ua = Net::Amazon->new(token => '1HNDXRF1YQR9X54K9R02',  
		secret_key => 'eWIPQ1bscu/AhDQQ3QLCMCRnXah30QhmovqgZKbk');
 my $dbh = DBI->connect( "dbi:mysql:HIJINX01", "dan", "rliump" )
          || die "can't connect to HIJINX01:$!\n"  ;
my $sth = $dbh->prepare("select isbn, title, id, in_stock - 1 as qty from books where in_stock > 1 order by title  limit 100");
my $sth2 = $dbh->prepare("select count(isbn) as sold from notes where isbn = ?");
$sth->execute;
while (my ($isbn, $title, $id, $qty) = $sth->fetchrow_array){
        my $response = $ua->search(asin => $isbn);
	if($response->is_success()){
		#print $response->as_string(), "\n";
		$sth2->execute($isbn) || warn "can't get sold count";
		my ($sold) = $sth2->fetchrow_array;
		for ($response->properties){
		 	my $ProductName = $_->ProductName();
		 	my $ListPrice = $_->ListPrice();
		 	my $AmazonPrice = $_->OurPrice();
		 	$ListPrice =~ s/\$//;
		 	my $ThirdPartyNewPrice = $_->ThirdPartyNewPrice();
		 	my $UsedPrice = $ThirdPartyNewPrice;
		 	$UsedPrice =~ s/\$//;
			if ($sold <= 3 ){
				print "$ProductName\nisbn:$isbn\nsurplus:$qty sold:$sold\nList Price:$ListPrice  Amazon:$AmazonPrice 3rd Party Price:$UsedPrice\n\n"; 
			}else{
				#print "$ProductName\nisbn:$isbn\nsurplus:$qty sold:$sold\nList Price:$ListPrice  Used Price:$UsedPrice\nDIFFERENCE:$diff\n\n"; 
			};
		}
	}else{
		print "Error: ", $response->message(), " $title\n";
	}
	
}
