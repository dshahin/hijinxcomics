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
my $sqlite = DBI->connect( "dbi:SQLite:dbname=previews.db", "", "" ) or die "can't connect!" ;
my $mysql = DBI->connect( "dbi:mysql:HIJINX01",  "dan", "rliump" ) or die "can't connect!" ;
#SQL statement handlers
my $sth2 = $mysql->prepare("select * from orders limit 1");
my $sth3 = $mysql->prepare("select * from orders where batchno = '200707' ");

$sth2->execute() || die "can't execute sth2:", $sth2->errstr;
$sqlite->do("begin transaction ") or die "can't create transaction";
$sqlite->do("drop table if exists items");
$sqlite->do("drop table if exists publishers");
$sqlite->do("create table if not exists publishers(id int, name)");
$sqlite->do("create table if not exists items(id integer primary key, batchno, itemno, discountcode,itemdescription, category int,
				vendor, genre, brand, shipdate, oicdate, 
				upc, pagenumber, adult, offeredagain,caution1,
				caution2, caution3, caution4, mature, resolicited,
				marvelfullline, price, srp, cost, issue,
				noteprice, parentitem, maxissue, stockcode, seriescode,
				previews_description, hijinx_id, qty, linenum)") 
		|| die "can't create table\n";
my $sth4 = $sqlite->prepare("insert into items values(NULL,?,?,?,?,?,?,?,?,?,?, ?,?,?,?,?,?,?,?,?,?, ?,?,?,?,?,?,?,?,?,?, ?,?,?,?) ");
$sth3->execute() || die "can't execute sth3:", $sth3->errstr;
while (my $i = $sth3->fetchrow_hashref){
	$i->{'category'} =~ s/ //g;
	$sth4->execute($i->{'batchno'},$i->{'itemno'},$i->{'discountcode'},$i->{'itemdescription'},$i->{'category'},
				$i->{'vendor'},$i->{'genre'},$i->{'brand'},$i->{'shipdate'},$i->{'oicdate'},
				$i->{'upc'},$i->{'pagenumber'},$i->{'adult'},$i->{'offeredagain'},$i->{'caution1'},
				$i->{'caution2'},$i->{'caution3'},$i->{'caution4'},$i->{'mature'},$i->{'resolicited'},
                                $i->{'marvelfullline'},$i->{'price'},$i->{'srp'},$i->{'cost'},$i->{'issue'},
                                $i->{'noteprice'},$i->{'parentitem'},$i->{'maxissue'},$i->{'stockcode'},$i->{'seriescode'},
                                $i->{'previews_description'},$i->{'hijinx_id'},$i->{'qty'},$i->{'linenum'}) || die "can't insert sth4"
}
my $sth5 = $mysql->prepare("select * from vendor ") || die "can't prep 5";
my $sth6 = $sqlite->prepare("insert into publishers values(?,?)") || die "can't prep 6";
$sth5->execute();
while ( my $v = $sth5->fetchrow_hashref){
	chomp($v->{'name'});
	chop ($v->{'name'});
	$sth6->execute($v->{'id'},$v->{'name'}) || warn "can't insert new pub" ;
}
$sqlite->do("create view vendor_count as select name as name, count(itemdescription) as count from items, publishers where items.vendor=publishers.id group by name");



$sqlite->do("commit transaction ");
