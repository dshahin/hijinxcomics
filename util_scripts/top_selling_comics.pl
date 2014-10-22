#!/usr/bin/perl

use DBI;
my $limit = shift || 50;
my $dbh = DBI->connect( "dbi:mysql:HIJINX01",  "dan", "");
my $sth = $dbh->prepare("select this_week.id as id, titles.name as title from this_week, titles where this_week.id = titles.id ");
my $sth2 = $dbh->prepare("select issue, rcv_qty - week_2 as sold, dcd from cycles where title_id = ? 
			order by issue desc limit 1" );
my $sth3 = $dbh->prepare("select previews_description from orders where itemno=? limit 1");

$sth->execute() || die "can't do it" ;
my %comics;
while(my ($id, $title) = $sth->fetchrow_array){
	$sth2->execute($id);
	my ($issue, $sold, $dcd) = $sth2->fetchrow_array;
	$comics{"$title #$issue"} = $sold;
}
@sorted = sort { $comics{$b} <=> $comics{$a} } keys %comics; 
#print @sorted;
foreach my $comic (@sorted){
print "<li>$comic\n";

}

