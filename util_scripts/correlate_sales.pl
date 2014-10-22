#!/usr/bin/perl
# correlate a sale with the other customers.

use DBI;

sub correlate {
    my ($user_id, $isbn) = @_;
    my $dbh = DBI->connect( "dbi:mysql:HIJINX01",  "dan", "");
    my $sth = $dbh->prepare("update customer_affinity set count = count+1 where cust1=? and cust2=(select customer from isbn_customer where isbn=?)");
    $sth->execute($user_id, $ibsn);
}

sub main {
    my $user_id = $ARGV[0];
    my $isbn = $ARGV[1];
    &correlate($user_id, $isbn);
}

&main();
