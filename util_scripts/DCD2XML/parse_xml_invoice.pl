#!/usr/bin/perl

#   Copyright 2007 Daniel J Shahin
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; version 2 of the License.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.

use lib qw( /home/dan/usr/local/lib/perl5/site_perl/5.8.7/
 /home/dan/usr/local/lib/perl5/site_perl/5.8.5/
		/home/dan/cpro.hijinxcomics.com/hijinx);

use XML::Simple;
use Data::Dumper;
use Business::ISBN qw(is_valid_checksum);
my $file = shift or die "error: must provide xml filename\n";
my $ref = XMLin($file);
my $total = 0;
my $retail = 0;
my $items = $ref->{'items'}->{'item'}; #make $items a handy reference to the items array
foreach my $i (@$items){ #step through items array
	if ($i->{'category'} == 3 || $i->{'category'} == 4){ #it's a book
		if ( is_valid_checksum($i->{'isbn'}) eq Business::ISBN::BAD_ISBN){
			print "bad isbn: ", $i->{'description'}, " ",  
				$i->{'item-code'}, " ",  $i->{'isbn'}, "\n";
			
		}
	}
	$total += $i->{'invoice-amount'};
	$retail += $i->{'retail-price'} * $i->{'units-shipped'};
	
}
print "warehouse: ", $ref->{'warehouse'}, "\n";
print "total cost: $total\n";
print "total retail: $retail\n";
#useful for debugging
#print Dumper($array_ref);
