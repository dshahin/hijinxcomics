#!/usr/bin/perl



sub suggest{
    my $self = shift;
    my $dbh  = $self->{dbh};
	my $isbn = shift;
        my $default_id = $self->param(default_id) || 0;
	my $sth = $dbh->prepare("select distinct customer_id from notes where isbn = ? and customer_id != $default_id and customer_id != 1278" ); # 476 is the default member 1278 = comicbookshelf.com
	my $sth2 = $dbh->prepare("select distinct isbn from notes where notes.customer_id = ? and isbn > 0");
	my $sth3 = $dbh->prepare("select title, isbn from books where isbn = ?");

	$sth->execute($isbn) || die "can't do it" ;
	my %books;
	my @suggestions;
	while(my $customer = $sth->fetchrow_hashref){
		$sth2->execute($customer->{"customer_id"})|| die "can't get last checkin: $!";
		while(my $book = $sth2->fetchrow_hashref){
			$books{$book->{"isbn"}}++ ;
		}
	}


	foreach $key (sort { $books{$b} <=> $books{$a} } keys %books){
		unless ($key eq $isbn || $books{$key} == 1 ){
			$sth3->execute($key) || die "can't do it" ;
			my $title;
			while(my $sugg = $sth3->fetchrow_hashref){
				$sugg->{title} .= " (+$books{$key})";
				push (@suggestions,$sugg);
			}
		}
	}
	return \@suggestions;
}
