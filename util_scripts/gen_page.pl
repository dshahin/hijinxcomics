#!/usr/bin/perl
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);

use HTML::Template;
use LWP::Simple;
use URI::Escape;
use XML::RSS;

#load config file
require("./config.pl");  
#load template
my $arg = shift;
my $quiet = 0;
if ($arg eq "-q"){ $quiet = 1};
my $template = HTML::Template->new(filename => 'templates/index.tmpl.html');
#my $news_template = HTML::Template->new(filename => 'templates/all_news.tmpl.html');

my @comics_loop = ();
my @books_loop = ();
my @comics = ();
my %comics;
my @books = ();
my %books;
open (INVOICE, "data/invoice.txt")|| die "can't open data/invoice.txt:$!";
open (INDEX, ">html/index.html") || die "can't open html/index.html:$!";
open (NEWS, ">html/news.html") || die "can't open html/index.html:$!";
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
#
#my @all_feeds;
#my @all_feed_sources;
#foreach my $site (keys %$ALL_RSS){
	#my %desc;
	#$desc{'SITE'} = $site;
	#push (@all_feed_sources, \%desc);
	#my $rss = new XML::RSS;
	#print "getting $site...\n" if (!$quiet);
	#my $rdf = get($ALL_RSS->{$site}) || warn "can't get $site:$!\n";
	#eval {$rss->parse($rdf)};
	#if ($@) {
  		#print "Bad XML document!!\n" if (!$quiet);
	#} else {
  		#print "Good XML!\n" if (!$quiet);
	#}
#
	#foreach my $story(@{$rss->{'items'}}){
		#my %item;
		#$item{'TITLE'} = $story->{'title'};
		#$item{'LINK'} = $story->{'link'};
		#$item{'DESC'} = $story->{'description'};
		#$item{'SITE'} = $site;
		##$item{'DATE'} = $story->{'date'};
		#push (@all_feeds, \%item);
	#}
#
#}
#my @feeds;
#foreach my $site (sort keys %$RSS_SITES){
	#my $rss = new XML::RSS;
	#print "getting $site...\n" if (!$quiet);
	#my $rdf = get($RSS_SITES->{$site}) || warn "can't get $site:$!\n";
	#eval {$rss->parse($rdf)};
	#if ($@) {
  		#print "Bad XML document!!\n" if (!$quiet);
	#} else {
  		#print "Good XML!\n" if (!$quiet);
	#}
#
	#foreach my $story(@{$rss->{'items'}}){
		#my %item;
		#$item{'TITLE'} = $story->{'title'};
		#$item{'LINK'} = $story->{'link'};
		#$item{'DESC'} = $story->{'description'};
		#$item{'SITE'} = $site;
		#$item{'DATE'} = $story->{'date'};
		#push (@feeds, \%item);
	#}
#
#}
#my @weblog;
#foreach my $site (sort keys %$WEBLOG){
	#my $rss = new XML::RSS;
	#print "getting $site...\n" if (!$quiet);
	#my $rdf = get($WEBLOG->{$site}) || warn "can't get $site:$!\n";
	#eval {$rss->parse($rdf)};
	#if ($@) {
  		#print "Bad weblog XML document!!\n" if (!$quiet);
	#} else {
  		#print "Good XML!\n" if (!$quiet);
	#}
	#my $count = 0;
	#foreach my $story(@{$rss->{'items'}}){
		###last if $count > 7;
		#my %item;
		#$item{'TITLE'} = $story->{'title'};
		#$item{'LINK'} = $story->{'link'};
		#$item{'DESC'} = $story->{'description'};
		#$item{'DATE'} = $story->{'date'};
		#push (@weblog, \%item);
		#$count++;
	#}
#
#}

sub bytitle {
       lc( $a->{'TITLE'}) cmp lc( $b->{'TITLE'});
}
my @sorted_feeds = sort bytitle @feeds;
my @sorted_feeds = sort bytitle @feeds;

my $FEED_DATE = `date`;

#my @image_keys = keys %$IMAGES;
#my $rand_key = $image_keys[rand @image_keys];
#if (! $quiet){print "IMAGE:$rand_key\n"};
	#my $rand_url = $IMAGES->{$rand_key};
#if (! $quiet){print "URL:$rand_url\n"};

#if (! $quiet){print "in store date: $SHELF_DATE\n"} ;
#$template->param( DATE=> $SHELF_DATE,  THIS_WEEK_COMICS => \@comics_loop, THIS_WEEK_BOOKS => \@books_loop, FEEDS => \@sorted_feeds, WEBLOG=> \@weblog );
$template->param( DATE=> $SHELF_DATE,  THIS_WEEK_COMICS => \@comics_loop, THIS_WEEK_BOOKS => \@books_loop  );
print INDEX $template->output;
#$news_template->param( FEEDS => \@all_feeds, FEED_SOURCES => \@all_feed_sources);
#print NEWS $news_template->output;

#system("perl gen_list.pl");
#system("perl gen_cart.pl");
if (! $quiet){
	system('cp html/index.html html/newcomics.html html/news.html  /home/danshahin/hijinxcomics.com/');
	print "index.html generated.  Upload to server?:";
	my $upload = <STDIN>;

	if ($upload =~ /y/i){
		system('cp html/index.html html/newcomics.html html/news.html  /home/danshahin/hijinxcomics.com/');
	}else{
		print "not uploaded\n";
	}
}else{
	system('cp html/index.html html/newcomics.html html/news.html  /home/danshahin/hijinxcomics.com/'); 
}
