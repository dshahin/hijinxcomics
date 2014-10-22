#!/usr/bin/perl
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);

use WWW::Mechanize;
my $rootdir = "MAR12";
#my $invoice = "/home/danshahin/work/hijinx/util_scripts/data/latest_order_form.txt"; ## POW File
my $invoice = "/home/danshahin/work/hijinx/util_scripts/data/latest_order_form.txt"; ## POW File
open INVOICE, $invoice or die "can't open order_form\n";
my $mech = WWW::Mechanize->new();
$mech->stack_depth(0);
$mech->agent_alias( 'Mac Mozilla' );
$mech->get( "https://retailer.diamondcomics.com/main/login.asp" );
	print $mech->content();
$mech->submit_form(
        form_name => 'LoginForm',
        fields      => {
            Login    => 'tru97814',
            Password    => 'red277sat',
        }
    );
my $outputdir = "/home/danshahin/hijinxcomics.com/images/previews/$rootdir";
#	print $mech->content();
print $outputdir
system "mkdir -p $rootdir/thumbs";
system "mkdir -p $rootdir/large";
system "mkdir -p $outputdir/thumbs";
system "mkdir -p $outputdir/large";
while (<INVOICE>){
        my @fields = split /\t/;
	next unless $fields[26] eq '';
        my $item = $fields[1];
        $item =~ s/\"//g;
	unless(-e "$outputdir/thumbs/$item.jpg"){
        $mech->get( "https://retailer.diamondcomics.com/main/ShoppingListAdd.asp?ItemNo=$item" ) || warn "cant get page for $item\n";
        my @content = split /\n/, $mech->content();
        my @stock = grep( /STK\d\d\d\d\d\d/, @content);
        my $stock =  $stock[0];
        $stock =~ s/^.*?(STK\d\d\d\d\d\d).*$/$1/;
	open (CANTFIND, ">>cantfind.txt");
        my $link = $mech->find_image( url_regex => qr/image-proc.asp/i );
        if ($link){
        		print "$item\n";
        		print "stock code $stock \n";
                $mech->get( $link->url_abs() );
                open OUTFILE, ">>$outputdir/thumbs/$item.jpg" || die "can't open thumbs";
                binmode OUTFILE;
                print OUTFILE $mech->content();
                close OUTFILE;
		print "..done\n";
				$mech->get( "https://retailer.diamondcomics.com/main/enlarge.asp?stockno=$stock" );
				my $link2 = $mech->find_image(  );
				if ($link2){
						$mech->get( $link2->url_abs() );
						open OUTFILE, ">>$outputdir/large/$item.jpg" || die "can't open large";
						binmode OUTFILE;
						print OUTFILE $mech->content();
						close OUTFILE;
						print "..done\n";
				}
        }else{
			print STDERR "can't find:$item,$stock\n";
			print CANTFIND "$item,$stock\n";
			system "cp ./cantfind.jpeg $outputdir/thumbs/$item.jpg";
			system "cp ./cantfind.jpeg $outputdir/large/$item.jpg";
	}
	close CANTFIND;
}
}
