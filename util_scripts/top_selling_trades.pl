#!/usr/bin/perl

use DBI;
my $limit = shift || 100;
my $dbh = DBI->connect( "dbi:mysql:HIJINX01",  "dan", "");
my $dbh2 = DBI->connect( "dbi:mysql:HIJINX20",  "dan", "");
#my $sth = $dbh->prepare("select count(notes.isbn) as count, notes.isbn as isbn,  notes.note as note, books.dcd as dcd from notes, books where notes.note like '%07\/%\/07%'  and notes.isbn > 0 and notes.isbn = books.isbn  group by isbn order by count desc limit $limit;" );
my $sth = $dbh->prepare("select count(notes.isbn) as count, notes.isbn as isbn,  notes.note as note, books.dcd as dcd from notes, books where notes.isbn > 0 and notes.isbn = books.isbn  group by isbn order by count desc limit $limit;" );

my $sth2 = $dbh2->prepare("select id, title from books where isbn = ?");
$sth->execute() || die "can't do it" ;
my %books;
my $num = 0;
while(my $item = $sth->fetchrow_hashref){
	$num++;
	 my $count = $item->{'count'};
	 my $isbn = $item->{'isbn'};
	$sth2->execute($isbn) || die "can't do 2";
	my ($id, $title) =  $sth2->fetchrow_array;
	chomp ($title, $isbn, $count, $dcd);
	#print "$count\t$title\t$isbn\t$dcd\n";
        #print "<li><a href=http://www.comicbookshelf.com/store?rm=detail&id=$id><img src=http://www.comicbookshelf.com/isbn?isbn=$isbn&size=2></a><br>$title\n";
        print "$isbn\n";
}

