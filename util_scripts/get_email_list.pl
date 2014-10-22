#!/usr/bin/perl
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);

use DBI;
use Email::Valid;
my $dbh = DBI->connect( "dbi:mysql:HIJINX01",  "dan", "") || die "can't connect";
my $dbh2 = DBI->connect( "dbi:mysql:HIJINX20",  "dan", "" || die "can't connect";
my $sth = $dbh->prepare("select email from customers where email != '' ") || die "can't prep";
my $sth2 = $dbh->prepare("select email from book_club where email != '' ") || die "can't prep";
my $sth3 = $dbh2->prepare("select email from passwd where opt_in = 1") || die "can't prep";


$sth->execute() || die "can't execute" . $sth->errstr;
$sth2->execute() || die "can't execute" . $sth2->errstr;
$sth3->execute() || die "can't execute" . $sth3->errstr;
while(my $cust = $sth->fetchrow_hashref){
	if (Email::Valid->address($cust->{"email"})){
		print  $cust->{"email"}, "\n";
	}
}
while(my $cust = $sth2->fetchrow_hashref){
	if (Email::Valid->address($cust->{"email"})){
		print  $cust->{"email"}, "\n";
	}
}
while(my $cust = $sth3->fetchrow_hashref){
	if (Email::Valid->address($cust->{"email"})){
		print  $cust->{"email"}, "\n";
	}
}

