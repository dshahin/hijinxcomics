#!/usr/bin/perl
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);

use HTML::Template;
use DBI;
my $limit = shift || 100;
my $dbh = DBI->connect( "dbi:mysql:HIJINX01",  "dan", "");
my $dbh2 = DBI->connect( "dbi:mysql:HIJINX20",  "dan", "");
my $sth = $dbh->prepare("select count(notes.isbn) as count, notes.isbn as isbn,  notes.note as note, books.dcd as dcd from notes, books where notes.isbn > 0 and notes.isbn = books.isbn  group by isbn order by count desc limit $limit;" );
my $sth2 = $dbh2->prepare("select title,info, id, price  from books where isbn = ?" );
my $sth3 = $dbh2->prepare("select avg(rank) as avg_rank  from reviews where book_id = ?" );
my $template = HTML::Template->new( filehandle =>*DATA, die_on_bad_params => 0 );
$sth->execute() || die "can't do it" ;
my %books;
my $rank = 0;
my @items;
while(my $item = $sth->fetchrow_hashref){
         $rank++;
        $sth2->execute($item->{'isbn'}) || die "can't execute";
        my ($title,$info,$id,$price) = $sth2->fetchrow_array();
        $sth3->execute($id) || die "can't execute";
        my ($avg_rank) = $sth3->fetchrow_array();
	$title =~ s/&/&amp;/;
        if ($info eq "no info"){$info = ""};
        #$item->{'info'} = $info;
        $item->{'id'} = $id;
        $item->{'rank'} = $rank;
        $item->{'avg_rank'} = $avg_rank;
        $item->{'title'} = $title;
        $item->{'price'} = $price;
        if($title){ push(@items, $item)};
	#print "$rank\t$title\t$isbn\t$dcd\t$info\n";
}
$items = \@items;
$template->param(ITEMS => $items,);
print $template->output;

__DATA__
<TOP_200>
<TMPL_LOOP NAME=ITEMS><TITLE ID="<TMPL_VAR NAME=ID>" NAME="<TMPL_VAR NAME=TITLE>" PRICE="<TMPL_VAR NAME=PRICE>" ISBN="<TMPL_VAR NAME=ISBN>" COUNT="<TMPL_VAR NAME=COUNT>" RANK="<TMPL_VAR NAME=RANK>" AVG_RANK="<TMPL_VAR NAME=AVG_RANK>" />
</TMPL_LOOP>
</TOP_200>
