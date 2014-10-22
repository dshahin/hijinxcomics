#!/usr/bin/perl

use DBI;

my $dbh = DBI->connect( "dbi:mysql:hijinx",  "hijinx", "passwerd");
my $sth = $dbh->prepare("select id, name from customers order by id" );
my $sth2 = $dbh->prepare("select date from checkin where checkin.id = ? order by date desc limit 1");
my $sth3 = $dbh->prepare("update customers set checkin = ? where id = ?");

$sth->execute();
while(my $customer = $sth->fetchrow_hashref){
	$sth2->execute($customer->{"id"})|| die "can't get last checkin: $!";
	while(my $checkin = $sth2->fetchrow_hashref){
		print $customer->{"id"},"\t", $checkin->{"date"}, "\n";
		$sth3->execute($checkin->{"date"},$customer->{"id"})||die "can't update checkins:$!";
	}
}
