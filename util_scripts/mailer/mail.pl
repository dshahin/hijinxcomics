#!/usr/bin/perl

use Mail::RFC822::Address qw(valid);
require Mail::Send;
open (ADDRESSES, "addresses.txt")||die "can't open addresses:$!" ;
open (SUBJECT, "subject.txt")||die "can't open subject:$!";
open (BODY, "body.txt")||die "can't open body:$!";
my $from = 'dan@hijinxcomics.com';
my $subject = <SUBJECT>;
my @body = <BODY>;
while(<ADDRESSES>){
	chomp;
	if (valid($_)){
		my $msg = new Mail::Send;
		$msg->set("From", $from );
		$msg->to($_);
		$msg->subject($subject);
		my $fh = $msg->open;
		print $fh @body;
		$fh->close || warn "can't send message:$!";
		print "sent to $_\n";
	}else{
		print STDERR "$_ is invalid\n";
	}
}
close ADDRESSES;
