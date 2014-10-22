#!/usr/bin/perl

use DBI;
my $tag = "vendor:fantagraphics";
my $dbh = DBI->connect( "dbi:mysql:HIJINX01",  "dan", "rliump") || die "no connect:$!\n" ;
my $sth = $dbh->prepare("select id, title from books where isbn = ?" ) || die "no select:$!\n";
my $sth2 = $dbh->prepare("insert into tags values(?,'book','vendor:fantagraphics')" ) || die "no select:$!\n";
my $sth3 = $dbh->prepare("insert into tags values(?,'book',?)" ) || die "no select:$!\n";
while(<>){
	chomp;
	s/"//g;
	my ($isbn, $genre) = split /,/;
	$isbn =~ s/-//g;
	$sth->execute($isbn) || die "can't execute" . $sth->errstr . "\n";
	my ($id, $title) = $sth->fetchrow_array() ;
	if ($id > 1){
		$sth2->execute($id) || warn "foo";
		print "$id $title $isbn $genre\n";
	}
}
