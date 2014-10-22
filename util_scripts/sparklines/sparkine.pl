#!/usr/bin/perl 
use lib qw( /home/dan/usr/local/lib/perl5/site_perl/5.8.7/
 /home/dan/usr/local/lib/perl5/site_perl/5.8.5/
		/home/dan/cpro.hijinxcomics.com/hijinx);
use DBI;
use SQL::Library;
use GD::Graph::sparklines;
$db = 'dbi:mysql:HIJINX01';
$user = 'dan';
$dbpass = 'rliump';
my $sql = new SQL::Library { lib => 'sql.lib' };
my $title_string = "AMAZING%";
$dbh = DBI->connect( $db, $user, $dbpass) || die "can't connect:$!";
$sth2 = $dbh->prepare($sql->retr( 'get_titles' ));
$sth2->execute()|| die $sth2->errstr;

my $issue = 0;# latest issue number
my $last = 0; #latest issue sales
while (my $title = $sth2->fetchrow_hashref){
	my $title_id = $title->{'id'};
	my $title = $title->{'name'};
	$sth = $dbh->prepare($sql->retr( 'get_sales' ));
	my @sold;
    my @issues;
    $sth->execute($title_id) or die "can't execute $!";
	if ($sth->rows() > 0){
	    while (my $row = $sth->fetchrow_hashref){
		  push ( @issues, $row->{'issue'} );
		  push ( @sold, $row->{'sold'} );
		  $last = $row->{'sold'} ;
		  $issue = $row->{'issue'} ;
	    }
		my $data = [ \@issues, \@sold ];
		my $graph = GD::Graph::sparklines->new(100, 30) or die "can't make graph $!";
		my $gd = $graph->plot($data) or warn "can't plot png $!";
		open (PNG, ">images/$title_id.png") or die "can't open images/$title_id.png $!";
		print PNG $gd->png() || die "foobar $!";
		close PNG;
		print "<img src=images/$title_id.png> <b><font color=red>$last</font></b> $title #$issue<br>\n";
	}
}
