#!/usr/bin/perl 

use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5/
		/home/dan/cpro.hijinxcomics.com/test);
use DBI;
use HTML::Template;
	my $dbh = DBI->connect( "dbi:mysql:HIJINX01", "dan", "" )
	  || die "can't connect to $db:$!\n"  ;
    my $template = HTML::Template->new( filename => './subscriptions.tmpl.html', cache => 1 );
    my $sth      = $dbh->prepare(
        "select distinct titles.name from titles, 
                                this_week where titles.id = this_week.id 
                                order by titles.name"
      )
      or die "cant prep ";
    $sth->execute();
    my @titles;

    while ( my ($title) = $sth->fetchrow_array ) {
        push( @titles, $title );
    }
    my $sth2 = $dbh->prepare(
"select customers.name as customer from customers, titles, subscriptions 
                                        where subscriptions.title = titles.id and subscriptions.customer = customers.id
                                        and titles.name = ? and customers.frozen = 0 order by customer"
      )
      or die "cant prep ";
    print $template->output();
    print "<ol>\n";
    foreach my $title (@titles) {
        my @customers;
        print "<li><b>$title</b>";
        $sth2->execute($title) or die "cant execute";
        while ( my ($customer) = $sth2->fetchrow_array ) {
            push @customers, "<li>$customer";
        }
        my $length = @customers;
        print "(<b>", $length, "</b>)\n";
        print "<ol>\n";
        foreach (@customers) { print $_}
        print "</ol>\n";
    }
    print "</ol>\n";
    exit;

