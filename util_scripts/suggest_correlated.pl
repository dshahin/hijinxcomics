#!/usr/bin/perl
#recommends books for book club members

use DBI;
#use strict;

my $MAX_OVERLAP = 20;

sub get_customer_purchases {
    my ($cust) = @_;

    my $dbh = DBI->connect( "dbi:mysql:HIJINX01",  "dan", "");
    my $sth = $dbh->prepare("select isbn from notes where customer_id = ?");
    my @isbns;
    $sth->execute($cust);
    while($record = $sth->fetchrow_hashref) {
	push(@isbns, $record->{'isbn'});
    }

    return \@isbns;
}

sub suggest {
    my ($user_id) = @_;

    my $dbh = DBI->connect( "dbi:mysql:HIJINX01",  "dan", "");
    my $sth = $dbh->prepare("select cust2, count from customer_affinity where cust1 = ? order by count desc");
    $sth->execute($user_id) || croak $sth->errstr;
    
    my $overlap = 0;
    my $record;
    my %recomendations;
    while (($overlap < $MAX_OVERLAP) && ($record = $sth->fetchrow_hashref)) {
	$isbns = &get_customer_purchases($record->{'cust2'});
	foreach my $isbn (@{$isbns}) {
	    $recomendations{$isbn}++;
	}
	$overlap++;
    }

    $isbns = &get_customer_purchases($user_id);    
    foreach my $isbn (@{$isbns}) {
	delete $recomendations{$isbn};
    }
    
    my @suggestions;
    foreach $key (sort {$recomendations->{$b} <=> $recomendations->{$a}} keys %recomendations) {
	push (@suggestions, $recomendations{$key});
    }
    return \@suggestions;
}

sub main {
    my $user_id = $ARGV[0];

    $suggestions = &suggest($user_id);
    
    foreach $suggestion (@{$suggestions}) {
	print "$suggestions\n";
    }
}

&main();
