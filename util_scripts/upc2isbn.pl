#!/usr/bin/perl

use Business::ISBN qw(ean_to_isbn);
my $upc = shift;
$upc = substr($upc, 0, 13);
my $isbn = ean_to_isbn($upc);
print "$isbn\n";

