#!/usr/bin/perl
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);
use LWP::Simple;
use URI::Escape;
use XML::RSS;

#my $url= shift;
#my $safeurl = uri_escape($url);
#my $content = get($url) || die "can't get $url";
#print $url;
my $content = get("http://cpro.hijinxcomics.com/store?rm=user_reviews&user_id=1&op=rss") || die "can't get it\n";
my $rss = new XML::RSS;

eval {$rss->parse($content) || die "can't"};
        if ($@) { 
                print "Bad XML document!!\n" if (!$quiet);
        } else {
                print "Good XML!\n" if (!$quiet);
        } 
foreach my $item(@{$rss->{'items'}}) {
	print "title: $item->{'title'}\n";
	print "link: $item->{'link'}\n";
	print "rank: " . $item->{"http://www.hijinxcomics.com"}->{rank} . "\n";
	print "isbn: " . $item->{"http://www.hijinxcomics.com"}->{isbn} . "\n";
	print "image: " . $item->{"http://www.hijinxcomics.com"}->{image} . "\n";
}

