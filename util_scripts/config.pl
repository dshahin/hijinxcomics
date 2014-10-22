#!/usr/bin/perl

our $SHELF_DATE = "Wednesday December 21st, 2011";
our $DIAMOND_ID = "tru";
our $DIAMOND_PASS = "";
our $IMAGES = {
	"charliebrown.jpg" => "http://www.charlesmschulzmuseum.org/",
    "derekkim.gif" => "http://www.moderntales.com/derekkirk/Comics/SameDifference/SameDifferenceIndex.htm",
	"hate1.jpg" => "http://www.peterbagge.com/",
	"fleep.gif" => "http://www.shigabooks.com/",
    #"hpekar.gif" => "http://www.harveypekar.com/",
    #"sacco.jpg" => "http://www.fantagraphics.com/artist/sacco/sacco_bio.html",
    #"LCD_0_thumb.jpg" => "http://www.lcdcomic.com",
	#"hi-jinx.thumb.jpg" => "http://www.wackyhijinx.com/images/hi-jinx.jpg",
	#"bobhope.jpg" => "http://flat_earth.blogspot.com/2003_07_27_flat_earth_archive.html#105945380893724269",
	#"blankets.jpg" => "http://www.topshelfcomix.com/preview.php?preview=blankets&page=1",
	#"hijinxcode.jpg" => "http://www.cafeshops.com/hijinx_comics",
};
#our $WEBLOG = {"hijinx comics" => 'http://del.icio.us/rss/hijinx/hijinx'};
our $WEBLOG = {"hijinx comics" => 'http://www.hijinxcomics.com/blog/index.rss',
#"favorite blogs" => 'http://www.google.com/reader/atom/user/01004817912387646169/state/com.google/starred',
#"hijinx calendar" => 'http://www.google.com/calendar/feeds/3cjddcv1emmt23c74s250n14f8@group.calendar.google.com/public/basic',
};
our $RSS_SITES = { 
	#"comic book resources" => 'http://myrss.com/f/c/b/cbrCcW8rnzh1.rss',
	#"journalista" => 'http://www.tcj.com/journalista/journalista.rss',
	#"the comics reporter" => 'http://www.comicsreporter.com/index.php/briefings/rss_1.0/',
	#"drawn.ca" => 'http://drawn.ca/feed/',
	#"comicbookshelf.com" => 'http://www.comicbookshelf.com/?rm=user_reviews&user_id=1&op=rss',
	#"newsarama" => 'http://www.newsarama.com/newsarama.rss'
	
};

our $ALL_RSS ={
	"hijinx comics" => 'http://www.wackyhijinx.com/perl/blosxom.cgi/index.rss',
	
}

