#!/usr/bin/perl

use lib qw( /home/danshahin/perlmods/ /home/danshahin/perlmods/share/perl/5.8.8/);

my $code  = shift || die "usage: update_files.pl <200801>\n";

use WWW::Mechanize;
my $mech = WWW::Mechanize->new();
$mech->agent_alias( 'Mac Safari' );
#$mech->get( "https://retailer.diamondcomics.com/main/login.asp" );
$mech->get( "https://retailerorders.diamondcomics.com/Login/Login" );
$mech->submit_form(
        #form_name => 'Login',
        fields      => {
			EnteredCustNo => '',
            UserName    => 'tru',
            Password    => ''
        },
		button    => 'Login'
    );

$mech->get( "https://retailerorders.diamondcomics.com/" ) 
	|| die "can't get order form: $code $! \n";
print $mech->content();

#print "fetching order form ";
#open(OF, ">latest_order_form.txt") || die "can't open latest order form";
#open(AOF, ">order_forms/OF$code.txt") || die "can't open archive  order form";
#$mech->get( "https://retailer.diamondcomics.com/main/file-export.asp?pd=powOF&pf=OF$code.txt" ) 
	#|| die "can't get order form: $code $! \n";
#print ". ";
#print OF $mech->content();
#print ". ";
#print AOF $mech->content();
#print "done\n ";
#
#print "fetching previews  ";
#open(PREVIEWS, ">latest_previews.txt") || die "can't open latest previews";
#open(A_PREVIEWS, ">previews/$code.previews.txt") || die "can't open archive previews";
#open(M_PREVIEWS, ">>master_previews.txt") || die "can't open master previews";
#$mech->get( "https://retailer.diamondcomics.com/main/file-export.asp?c=1&pd=monthly_tools/txt&pf=previewsDB.txt" );
#print ". ";
#print PREVIEWS $mech->content();
#print ". ";
#print A_PREVIEWS $mech->content();
#print ". ";
#print M_PREVIEWS $mech->content();
print "done\n ";


