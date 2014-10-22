#!/usr/bin/perl

use lib qw( /home/dan/usr/local/lib/perl5/site_perl/5.8.7/
 /home/dan/usr/local/lib/perl5/site_perl/5.8.5/
/home/dan/cpro.hijinxcomics.com/hijinx);
use DBI;
my $sqlite = DBI->connect( "dbi:SQLite:dbname=previews.db", "", "" ) or die "can't connect!" ;
my $limit = shift || 10;

my $sth7 = $sqlite->prepare( "select * from vendor_count order by count desc limit ?") || die "can't create sth7";
$sth7->execute($limit);
while (my $i = $sth7->fetchrow_hashref){
	print "$i->{name} : $i->{count} \n";
}
