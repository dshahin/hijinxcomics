#!/usr/bin/perl

use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);

use DBI;
use WWW::Mechanize;
use SQL::Library;
my $batchno = shift || die "must provide batchno (eg: 200712)";
my $sqlite = DBI->connect( "dbi:SQLite:dbname=master.db", "", "" );
my $sqlib = new SQL::Library {lib => [<DATA>]};
my $mysql = DBI->connect( "dbi:mysql:HIJIN", "d", "p" )
          || die "can't connect to $db:$!\n"  ;
my $mech = WWW::Mechanize->new();
$mech->agent_alias( 'Windows IE 6' );
$mech->get( "https://retailer.diamondcomics.com/main/login.asp" );
$mech->submit_form(
        form_name => 'form1',
        fields      => {
            Login    => 'tru',
            Password    => '',
        }
    );

my $query1 =$sqlib->retr('create_items_table');
$sqlite->do($query1) || die "can't do it!";
my $query2 =$sqlib->retr('insert_item');
my $query3 =$sqlib->retr('get_descriptions');

my $sth = $sqlite->prepare($query2) || die "can't prep";
my $sth2 = $mysql->prepare($query3) || die "can't prep mysql";
print "fetching order form ";
open(OF, ">master_data.txt") || die "can't open latest order form";
$mech->get( "https://retailer.diamondcomics.com/main/file-export.asp?pd=misc_file_downloads&pf=MasterDataFile-ITEMS.txt" ) 
	|| die "can't get order form: $code $! \n";
print ". ";
print OF $mech->content();
print ". ";
print "done\n ";
close(OF);
open (MASTER, "master_data.txt");

my $num = 0;

$sth2->execute($batchno) || die "can't execute mysql";
my %descr;
while( my $item = $sth2->fetchrow_hashref){
	$descr{$item->{'itemno'}} = $item->{'previews_description'} ;
}



$sqlite->do("begin");
while(<MASTER>){
	my @fields = split/\t/;
	$fields[39] = uc $fields[39];
	$fields[40] = uc $fields[40];
	$fields[41] = uc $fields[41];
	$fields[42] = $descr{$fields[0]};
	if ($num > 0){
		$sth->execute(@fields) || die "can't execute";
		print $fields[0] . "\n";
	}else{
		$num++;
	}
}
$sqlite->do("end");

__DATA__
[create_items_table]
create table if not exists items( DIAMD_NO PRIMARY KEY,STOCK_NO,PARENT_ITEM_NO_ALT,BOUNCE_USE_ITEM,FULL_TITLE,MAIN_DESC,VARIANT_DESC,SERIES_CODE,ISSUE_NO,ISSUE_SEQ_NO,VOLUME_TAG,MAX_ISSUE,PRICE,PUBLISHER,UPC_NO,ISBN_NO,EAN_NO,CARDS_PER_PACK,PACK_PER_BOX,BOX_PER_CASE,DISCOUNT_CODE,INCREMENT,PRNT_DATE,FOC_VENDOR,SHIP_DATE,SRP,CATEGORY INT,GENRE,BRAND_CODE,MATURE,ADULT,OA,CAUT1,CAUT2,CAUT3,RESOL,NOTE_PRICE,ORDER_FORM_NOTES,PAGE,WRITER,ARTIST,COVER_ARTIST,DESC)

[insert_item]
insert or replace 
into 	items 
values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)

[get_descriptions]
select 	itemno, 
	previews_description 
from 	orders 
where 	batchno = ?
