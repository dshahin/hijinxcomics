#!/usr/bin/perl
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);

use WWW::Mechanize;
my $isbn = shift;
chomp $isbn;
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
$mech->get( "https://retailer.diamondcomics.com/main/StockLookup.asp?QueryItem=$isbn" );
print $mech->content();
#my @page = split(/\n/, $mech->content());
#my @line = grep(/ShoppingListAdd/,@page);
#print $page[59];

