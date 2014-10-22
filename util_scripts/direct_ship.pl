#!/usr/bin/perl
use lib qw( /home/dan/usr/local/lib/perl5/site_perl/5.8.7/
 /home/dan/usr/local/lib/perl5/site_perl/5.8.5/
		/home/dan/cpro.hijinxcomics.com/hijinx);

use DBI;


my $dbh = DBI->connect( "dbi:mysql:HIJINX01",  "dan", "") || die "no connect:$!\n" ;
#receive invoice
#my $sth1 = $dbh->prepare("update books set in_stock = in_stock + ? , on_order = on_order - ? where dcd = ?" );
#un-receive invoice
my $sth1 = $dbh->prepare("update books set in_stock = in_stock - ? , on_order = on_order + ? where dcd = ?" );
my $sth2 = $dbh->prepare("select title from books where dcd = ?");

while(<>){
chomp;
($dcd,$received) = split /,/;
$sth1->execute($received,$received,$dcd) || warn "can't execute sth1", $sth1->errstr;
$sth2->execute($dcd) || warn "can't execute sth2", $sth2->errstr;
my ($title) = $sth2->fetchrow_array;
print $title, "\n" ;
print "itemcode: $dcd\tqty:$received\n";
}






