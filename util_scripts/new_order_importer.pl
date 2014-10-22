#!/usr/bin/perl 

#use strict;
use DBI;
my %instances = (
'hijinx' => 'hijinx1:mysql.hijinxcomics.dreamhosters.com',
#'collpar' => 'collpar:mysql.hijinxcomics.dreamhosters.com',
#'collpar2' => 'collpar2:mysql.hijinxcomics.dreamhosters.com',
#'test' => 'HIJINX04',
);

my $order_form = "data/latest_order_form.txt";
my $previews = "data/latest_previews.txt";

my @databases = sort values(%instances);
foreach my $db (@databases){
	print "starting $db\n";
	my $dbh = DBI->connect( "dbi:mysql:$db", "dshahin", "" )
	  || die "can't connect to $db:$!\n"  ;
	my $sth =
	  $dbh->prepare(
	"insert into orders values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
	  )
	  || die "no select:$!\n";
	my $sth2 = $dbh->prepare("select id from titles where name = ?")
	  || die "no select:$!\n";
	my $sth3 = $dbh->prepare("update orders set linenum = substring(itemno, 6,4) where itemno = ?;")
	  || die "no select:$!\n";
	my $sth4 = $dbh->prepare("insert into titles values(NULL,?,0)")
	  || die "no insert:$!\n";
	open( ORDER_FORM, $order_form ) || die "can't open latest_order_form.txt:$!";
	while (<ORDER_FORM>) {
	    my (
		$batchno,              $itemno,       $discountcode,
		$itemdescription,      $category,     $vendor,
		$genre,                $brand,        $shipdate,
		$oicdate,              $upc,          $pagenumber,
		$adult,                $offeredagain, $caution1,
		$caution2,             $caution3,     $caution4,
		$mature,               $resolicited,  $marvelfullline,
		$price,                $srp,          $cost,
		$issue,                $noteprice,    $parentitem,
		$maxissue,             $stockcode,    $seriescode,
		$previews_description, $hijinx_id,    $qty,
		$linenum
	      )
	      = split /\t/;
	    $qty     = 0;
	    $linenum = 0;
	    open( PREVIEWS, $previews )
	      || die "can't open previews:$!";
	    while (<PREVIEWS>) {
		s/\"//g;
		my ( $dcd, $title, $price, $desc ) = split /\t/;
		if ( $category == 1 ) {    # && $parentitem eq " "){
					   #print "$itemdescription\n";
		    my $status = $sth2->execute($itemdescription);
		    my $id     = 0;
		    if ( $status == 1 ) {
			$id = $sth2->fetchrow_array, "\n";
			$hijinx_id = $id;
		    }else{
					#title doesn't exist yet add it and get id
			$sth4->execute($itemdescription) || die "can't insert new title". $sth4->errstr;
			my $status = $sth2->execute($itemdescription) || die "can't insert new title". $sth2->errstr;
			$id = $sth2->fetchrow_array, "\n";
			$hijinx_id = $id;
					warn "adding new title: $itemdescription $hijinx_id\n";
				}
		}
		if ( $dcd eq $itemno ) {
		    $previews_description = $desc;
		    last;
		}

	    }
	    close PREVIEWS;
	    print "$db: $itemno $itemdescription $issue hijinx: $hijinx_id\n";
	    $sth->execute(
		$batchno,              $itemno,       $discountcode,
		$itemdescription,      $category,     $vendor,
		$genre,                $brand,        $shipdate,
		$oicdate,              $upc,          $pagenumber,
		$adult,                $offeredagain, $caution1,
		$caution2,             $caution3,     $caution4,
		$mature,               $resolicited,  $marvelfullline,
		$price,                $srp,          $cost,
		$issue,                $noteprice,    $parentitem,
		$maxissue,             $stockcode,    $seriescode,
		$previews_description, $hijinx_id,    $qty,
		$linenum
	      )
	      || warn "can't insert: $!\n";
	    $sth3->execute($itemno);

	}
}
