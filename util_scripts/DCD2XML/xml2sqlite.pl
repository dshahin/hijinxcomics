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
use DBI;
my $file = shift or die "must provide xml filename";
my $dbh = DBI->connect( "dbi:SQLite:dbname=invoice.db", "", "" ) or die "can't connect!" ;
#SQL statement handlers
$dbh->do("create table if not exists invoice(id integer primary key, units_shipped, item_code, item_description,
		  retail_price, unit_price, invoice_amount, category, order_type, processed_as, order_number, upc,
		isbn,ean,po_number,allocated )") || die "can't create table\n";
$dbh->do("create table if not exists info(date,account,warehouse)") || die "can't create table\n";
my $sth = $dbh->prepare("insert into invoice values (NULL,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ");
my $sth2 = $dbh->prepare("select sum(units_shipped) from invoice");
my $sth3 = $dbh->prepare("select count(distinct item_code)  from invoice");
my $sth4 = $dbh->prepare("select sum(units_shipped * retail_price) from invoice");

$dbh->do("begin transaction ") or die "can't create transaction";
$dbh->do("delete from invoice") || die "can't empty invoice table\n";
my $ref = XMLin($file, SuppressEmpty => '');
my $total = 0;
my $retail = 0;
my $items = $ref->{'items'}->{'item'}; #make $items a handy reference to the items array
foreach my $i (@$items){ #step through items array
	$sth->execute($i->{'units-shipped'}, $i->{'item-code'},$i->{'description'},$i->{'retail-price'},$i->{'unit-price'},
			$i->{'invoice-amount'}, $i->{'category'},$i->{'order-type'},$i->{'processed-as'},$i->{'order-number'},
			$i->{'upc'}, $i->{'isbn'},$i->{'ean'},$i->{'po-number'},$i->{'allocated'} ) || die "can't insert";
	#print $i->{'description'}, "\n";
	$total += $i->{'invoice-amount'};
	#sleep(1);
}
$dbh->do("commit transaction ") or die "can't commit";
$sth2->execute();
$sth3->execute();
$sth4->execute();
my $count = $sth2->fetchrow_array;
my $lcount = $sth3->fetchrow_array;
my $retail2 = $sth4->fetchrow_array;
print "piece count: $count\n";
print "line count: $lcount\n";
print "warehouse: ", $ref->{'warehouse'}, "\n";
print "account: ", $ref->{'account-number'}, "\n";
print "date: ", $ref->{'date'}, "\n";
print "total cost: $total\n";
print "total retail db: $retail2\n";
