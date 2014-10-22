#!/usr/bin/perl
use DBI;
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);
use Mail::RFC822::Address qw(valid);

my $dbh = DBI->connect( "dbi:mysql:HIJINX01",  "dan", "rliump");
my $sth = $dbh->prepare(" select email from book_club where email > '';"); # top 10% most active book club members
my $sth2 = $dbh->prepare(" select email from customers where email > '';"); # top 10% most active book club members
my %email;
$sth->execute();
while(my $sub = $sth->fetchrow_hashref){
	my $address = $sub->{'email'};
	if (valid($address)){
		$email{"$address\n"}++;
	}
}

$sth2->execute();
while(my $sub = $sth2->fetchrow_hashref){
	my $address = $sub->{'email'};
	if (valid($address)){
		$email{"$address\n"}++;
	}
}

print sort keys(%email)
