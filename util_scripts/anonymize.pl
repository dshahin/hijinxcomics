#!/usr/bin/perl
#anonymizer takes a hijinx db and removes the names and details of 
#customers

use DBI;
my $dbh = DBI->connect( "dbi:mysql:hijinx@gal",  "hijinx", "passwerd") || die "no connect:$!\n" ;
my $sth1 = $dbh->prepare("insert into passwd values(NULL,'demo','demo','0')") 
	|| die "no select:$!\n";
my $sth2 = $dbh->prepare("update customers set phone = '867-5309'");
my $sth3 = $dbh->prepare("update customers set email = 'foo\@bar.org'");
my $sth4 = $dbh->prepare("update book_club set phone = '867-5309'");
my $sth5 = $dbh->prepare("update book_club set email = 'foo\@bar.org'");
my $sth6 = $dbh->prepare("update customers set name = concat('jon doe ',id)");
my $sth7 = $dbh->prepare("update book_club set name = concat('jon doe ',id)");

$sth1->execute() || warn "cant do sth1";
$sth2->execute() || warn "cant do sth2";
$sth3->execute() || warn "cant do sth3";
$sth4->execute() || warn "cant do sth4";
$sth5->execute() || warn "cant do sth5";
$sth6->execute() || warn "cant do sth6";
$sth7->execute() || warn "cant do sth7";
