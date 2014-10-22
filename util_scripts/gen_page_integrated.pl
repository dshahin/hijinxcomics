#!/usr/bin/perl
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);

use HTML::Template;
use LWP::Simple;
use URI::Escape;
use XML::RSS;

chdir('/home/danshahin/work/hijinx/util_scripts');
#load config file
require("./config.pl");  
#load template
my $SHELF_DATE = shift || 'wednesday';
my $template = HTML::Template->new(filename => 'templates/index.tmpl.html');

my @comics_loop = ();
my @books_loop = ();
my @comics = ();
my %comics;
my @books = ();
my %books;
open (INVOICE, "data/invoice.generated.txt")|| die "can't open data/invoice.generated.txt:$!";
open (INDEX, ">html/index.html") || die "can't open html/index.html:$!";
while(<INVOICE>){	
	s/&amp;/&/g;
	my($quantity,$diamond,$discount,$description,$price,
	   $unit, $amt, $category,$type,$pow) = split /,/;
	$diamond =~ s/\"//g;
	$diamond =~ s/ //g;
	$diamond =~ s/\D$//g;
	$description =~ s/\"//g;
	$description =~ s/\(.*?\)//g;
	#$description = "<b>$description</b>" if ($pow == 1);;
	#if ($category == 1){	push(@comics, "$description,$diamond")};
	if ($category == 1 && $type == 1){	$comics{"$description,$diamond"} = 1};
	if (($category == 3 || $category == 4)&& $type == 1){$books{"$description,$diamond"} = 1 }
}

my @sorted_comics = sort(keys %comics);
my @sorted_books = sort(keys %books);
foreach my $book (@sorted_comics){
	my ($title, $diamond) = split( /,/, $book);
	my  %comic;
	$comic{'ISSUE'} = $title;
	#$comic{'POW'} = $pow;
	$comic{'CODE'} = $diamond;
	push(@comics_loop, \%comic);
}
foreach my $book (@sorted_books){
	my ($title, $diamond) = split( /,/, $book);
	my  %book;
	$book{'ISSUE'} = $title;
	#$book{'POW'} = $pow;
	$book{'CODE'} = $diamond;
	push(@books_loop, \%book);
}

sub bytitle {
       lc( $a->{'TITLE'}) cmp lc( $b->{'TITLE'});
}
my @sorted_feeds = sort bytitle @feeds;


$template->param( DATE=> $SHELF_DATE,  THIS_WEEK_COMICS => \@comics_loop, THIS_WEEK_BOOKS => \@books_loop  );
print INDEX $template->output;

#system("perl gen_list.pl");
#system("perl gen_cart.pl");

system('cp html/index.html  /home/danshahin/hijinxcomics.com/'); 
