#!/usr/bin/perl
#recommends books for book club members

use DBI;
my $user_id = shift;
my $dbh = DBI->connect( "dbi:mysql:HIJINX01",  "dan", "");
	my $sth = $dbh->prepare("select distinct isbn from notes where customer_id = ? and isbn > 0 ");
	my $sth2 = $dbh->prepare("select distinct customer_id from notes where isbn = ? " );
	my $sth3 = $dbh->prepare("select title from books where isbn = ?");
	my $sth4 = $dbh->prepare("select distinct isbn from notes where customer_id = ? and isbn > 0" );
        $sth->execute($user_id) || croak $sth->errstr;
        my @suggestions;
        my %prospects;
		my %peers;
        while (my $book = $sth->fetchrow_hashref){
                my $isbn = $book->{'isbn'};
                $sth2->execute($isbn) || croak $sth2->errstr;
                while (my $user = $sth2->fetchrow_hashref){
						my $user_id = $user->{'customer_id'};
						unless (exists $peers{$user_id}){
								$peers{$user_id}++;
								$sth4->execute($user_id);
								while (my $book = $sth4->fetchrow_hashref){
										unless (bought($book->{'isbn'})){ $prospects{$book->{'isbn'}}++ }
								}
                        }else{
							next;
						}
                }
        }
        foreach $key (sort { $prospects{$b} <=> $prospects{$a} } keys %prospects){
                        $sth3->execute($key) || die "can't do it 2" . $sth3->errstr ;
                        my $title;
                        while(my $book = $sth3->fetchrow_hashref){
				if ($prospects{$key} > 1){
					push (@suggestions,$book->{'title'} . " score: " . $prospects{$key});
				}
                        }
        }
        print join "\n",@suggestions;

sub bought{
        my $book_id = shift;
    my $sth  = $dbh->prepare( "select isbn from notes where isbn = ? and customer_id = ?");
        $sth->execute($book_id, $user_id) || croak $sth->errstr;
        if ($sth->rows){
		return 1;
		
        }else{
                return 0;
        }
}

