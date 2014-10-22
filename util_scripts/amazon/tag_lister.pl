#!/usr/bin/perl
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);
# sell a book on Amazon Marketplace
#
use DBI;
use Net::Amazon;
use WWW::Mechanize;

open (BOOKS, '>amazon_books.csv') || die "can't open output file";
my $condition = 'new-new';
my $tag = "amazon_over_6_again";
my $condition2 = 'collectible-mint';
my $comments = 'Brand new in great condition.  This is overstock from the shelves of Hijinx Comics in San Jose, voted best comic book shop in Silicon Valley, so your satisfaction is guaranteed.';
my @books;

my $mech = WWW::Mechanize->new;
my $ua = Net::Amazon->new(token => '1DSVSTQTDJQCGAC0KF02',);
my $dbh = DBI->connect( "dbi:mysql:HIJINX01", "dan", "rliump" ) || die "no connect:$!\n";
my $sth = $dbh->prepare("select books.isbn, books.title, books.id, books.in_stock as qty from books, tags where books.in_stock > 0 and tags.type = 'book' and tags.tag = ?  and books.id = tags.id order by books.id");
my $sth2 = $dbh->prepare("select count(isbn) as sold from notes where isbn = ?");
my $sth3 = $dbh->prepare("insert into tags values(?, 'book', ?)");
my $sth4 = $dbh->prepare("select books.isbn, books.title, books.id, books.in_stock as qty from books, tags where books.in_stock > 0 and tags.type = 'book' and tags.tag = ?  and books.id = tags.id order by books.id");
$sth4->execute("amazon_permalist") || die "can't get permanent items";
$sth->execute($tag);

print "permalist items:\n";
while ( my $book = $sth4->fetchrow_hashref ) {
		push @books, $book;
		print "$book->{title}\n";
}
while ( my $book = $sth->fetchrow_hashref ) {
		push @books, $book;
}
my $count = @books;
print "$count books to tag and/or list for tag: $tag\n";


foreach my $book (@books){
	my $response = $ua->search(asin => $book->{isbn});
	if($response->is_success()){
		for ($response->properties){
			$low_price =  $_->ThirdPartyNewPrice();
			$low_price =~ s/\$//;
			$book->{low_price} = $low_price - '.01' ;
		}
		print "$book->{title} $book->{low_price} $book->{id}\n";
		list_item($book);
	}else{
		next;
	}
}

sub list_item{

	my $book = shift;
	$mech->get("https://www.amazon.com/gp/sign-in.html");
	
	$mech->submit_form(
    	form_name => 'sign-in',
    	fields => {
        	email => 'dan@hijinxcomics.com',
        	password => 'p@sswerd'
    	}
    	);
	$mech->get("http://s1.amazon.com/exec/varzea/sdp/sai-condition/" . $book->{isbn}) || next;
	if ($mech->content() =~ /.*The item you indicated is ineligible for Amazon Marketplace selling.*/){
		next;
	}
	
	if ($mech->content() =~ /.*new-new.*/){
		$mech->submit_form(
    			form_number => 1,
    			fields => {
        		'sdp-sai-condition-type' => $condition,
        		'sdp-sai-condition-comments' => $comments
    			}
 		) ;
	}elsif ($mech->content() =~ /.*collectible-mint.*/){
		$mech->submit_form(
    			form_number => 1,
    			fields => {
        		'sdp-sai-condition-type' => $condition2,
        		'sdp-sai-condition-comments' => $comments
    			}
 		) ;
	
	}else{
		next;
	}
	$mech->submit_form(
    	form_number => 1,
    	fields => {
        	'selling-asking-price' => $book->{low_price},
        	'selling-new-available-quantity' => $book->{qty},
        	'selling-sku' => $book->{isbn}
    	}
    	);
	if ($mech->form_name( 'login' )){
		$mech->submit_form(
   	 	form_name => 'login',
    		fields => {
        		'input-login-email' => 'dan@hijinxcomics.com',
        		password => 'p@sswerd'
    		}
    	);
	}
	
	$mech->submit_form(
    	form_number => 1,
    	);
	
	print "$book->{qty}\t$book->{price}\t$book->{title} id:$book->{id} \n";
	return 1;
}
