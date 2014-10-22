#!/usr/bin/perl
use lib qw(/home/dan/usr/local/lib/perl5/site_perl/5.8.5
		/home/dan/cpro.hijinxcomics.com/hijinx);
  use Net::Amazon;

  my $ua = Net::Amazon->new(
        token      => '1HNDXRF1YQR9X54K9R02',
        secret_key => 'eWIPQ1bscu/AhDQQ3QLCMCRnXah30QhmovqgZKbk');

    # Get a request object
  my $response = $ua->search(asin => '0201360683');

  if($response->is_success()) {
      print $response->as_string(), "\n";
  } else {
      print "Error: ", $response->message(), "\n";
  }
