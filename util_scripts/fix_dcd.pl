#!/usr/bin/perl 

#use strict;
use DBI;
my %instances = (
'hijinx' => 'HIJINX01',
#'demo' => 'HIJINX02',
#'dev' => 'HIJINX03',
#'test' => 'HIJINX04',
#'mainstreet' => 'HIJINX05',
#'earth2' => 'HIJINX06',
#'essential' => 'HIJINX07',
#'hobbyshop' => 'HIJINX08',
#'drno' => 'HIJINX09',
#'greenbrain' => 'HIJINX10',
#'littlerocket' => 'HIJINX11',
#'3rdplanet' => 'HIJINX12',
#'monkey' => 'HIJINX13',
);
my @databases = sort values(%instances);
foreach my $db (@databases){
	print "starting $db\n";
	my $dbh = DBI->connect( "dbi:mysql:$db", "dan", "" )
	  || die "can't connect to $db:$!\n"  ;
	my $sth = $dbh->prepare( "select * from books where dcd is NULL") || die "no select:$!\n";
	my $sth2 = $dbh->prepare( "update books set dcd = ? where isbn = ? and  dcd is NULL") || die "no select:$!\n";
	$sth->execute || warn "can't select books";
	while (my $book = $sth->fetchrow_hashref()){
		my $isbn = $book->{'isbn'} ;
		my $dcd = `./isbn2dcd.pl $isbn`;
		print  $book->{'title'}." $isbn  $dcd \n";
		if ($dcd){
			print  $book->{'title'}." $isbn  $dcd \n";
			$sth2->execute($dcd, $isbn) || warn "can't select books";
		}else{
			print "can't get dcd code for ". $book->{'title'}." $isbn  $dcd \n";
		}
	}
}
