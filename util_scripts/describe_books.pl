!/usr/bin/perl
use lib qw( /home/dan/usr/local/lib/perl5/site_perl/5.8.7/
 /home/dan/usr/local/lib/perl5/site_perl/5.8.5/
		/home/dan/cpro.hijinxcomics.com/hijinx);

use DBI;


my $dbh = DBI->connect( "dbi:mysql:HIJINX20",  "dan", "") || die "no connect:$!\n" ;
my $sth1 = $dbh->prepare("select dcd, id from books where dcd != 1 and dcd != '' order by id desc" );
my $sth2 = $dbh->prepare("update books set info = ? where id = ?" );


$sth1->execute() || warn "can't execute sth1", $sth1->errstr;
while ( my $book = $sth1->fetchrow_hashref ) {
        my $book_id = $book->{'id'};
	my $dcd = $book->{'dcd'};
	if ($dcd =~ /STAR/){ next };
	open PREVIEWS, "data/master_previews.txt";
	while (<PREVIEWS>){
		my ($code, $title, $price, $desc) = split /\t/;
		$title =~ s/\"//g;
		$code =~ s/\"//g;
		$code =~ s/\s$//g;
		if ($dcd eq $code){
			print "update: $dcd\n$book_id\n$title\n";
			print "desc:$desc\n";
			$sth2->execute($desc,$book_id)|| die "can't update info". $sth2->errstr;
		}
	}
}







