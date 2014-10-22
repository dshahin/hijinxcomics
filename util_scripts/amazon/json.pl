#!/usr/bin/perl
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);
# sell a book on Amazon Marketplace
#

use DBI;
use JSON;
my $json = new JSON;
my $dbh = DBI->connect( "dbi:mysql:HIJINX01", "dan", "rliump" )
          || die "can't connect to HIJINX01:$!\n"  ;
my $sth = $dbh->prepare("select * from books where isbn = ?");

my $isbn = shift || '0930289234';
$sth->execute($isbn) || die "can't run select " .  $sth->errstr;

my $book = $sth->fetchrow_hashref;
$json_text   =  $json->pretty->encode($book);
print $json_text;
