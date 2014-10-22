#!/usr/bin/perl
use lib qw( /home/danshahin/perlmods/ /home/danshahin/perlmods/share/perl/5.8.8/);
# sell a book on Amazon Marketplace
#
use DBI;
use Net::Amazon;
use WWW::Mechanize;

open (BOOKS, '>amazon_books.csv') || die "can't open output file";
my $condition = 'new-new';
my $tagname = 'amazon_over_25_12_16_2009';
my $condition2 = 'collectible-mint';
my $comments = 'Brand new in great condition.  This is overstock from the shelves of Hijinx Comics in San Jose, so your satisfaction is guaranteed.';
my @books;

my $mech = WWW::Mechanize->new;
my $ua = Net::Amazon->new(token => '1HNDXRF1YQR9X54K9R02', secret_key => 'eWIPQ1bscu/AhDQQ3QLCMCRnXah30QhmovqgZKbk');
my $dbh = DBI->connect( "dbi:mysql:hijinx1:mysql.hijinxcomics.dreamhosters.com", "dshahin", "rliump" ) || die "no connect:$!\n";
my $sth = $dbh->prepare("select isbn, title, id, in_stock as qty from books where in_stock > 0 and id < 8000  order by id");
my $sth2 = $dbh->prepare("select count(isbn) as sold from notes where isbn = ?");
my $sth3 = $dbh->prepare("insert into tags values(?, 'book', ?)");
$sth->execute();

while ( my $book = $sth->fetchrow_hashref ) {
	$sth2->execute($book->{isbn}) || warn "can't get sold count";
	$book->{sold} = $sth2->fetchrow_array;
	if ( $book->{sold} <= 3){
		push @books, $book;
		
	}else{
		next;
	}
}
my $count = @books;
print "$count books to tag and/or list\n";


foreach my $book (@books){
	my $response = $ua->search(asin => $book->{isbn});
	if($response->is_success()){
		for ($response->properties){
			$low_price =  $_->ThirdPartyNewPrice();
			$book->{low_price} = $low_price;
			$low_price =~ s/\$//;
			if ($low_price > 25){
				my $lower_price = $low_price - '.05';
				tag_book($book, $tagname);
				print "$low_price $book->{title} $lower_price $book->{id}\n";
			}
		}
	}else{
		next;
	}
}

sub tag_book{
	my $book = shift;
	my $tag = shift;
	$sth3->execute($book->{id},$tag) || warn "can't tag book $book->{id}";
	return 1;
}

