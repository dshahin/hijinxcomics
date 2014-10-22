#!/usr/bin/perl
use DBI;
use HTML::Template;
use Mail::RFC822::Address qw(valid);
require Mail::Send;

my $dbh = DBI->connect( "dbi:mysql:hijinx",  "hijinx", "passwerd");
#choose and uncomment a statement handler, or write your own
#my $sth = $dbh->prepare("select email, name, credit from book_club where email != '' order by credit desc"); # all club members with email
my $sth = $dbh->prepare("select  book_club.name as name, book_club.email, book_club.credit as credit, count(notes.note) as books from notes, book_club where book_club.id = notes.customer_id and email != '' group by name order by books desc limit 52"); # top 10% most active book club members

my $template = HTML::Template->new(filename => 'body.tmpl', die_on_bad_params => 1);
my $subject_template = HTML::Template->new(filename => 'subject.tmpl', die_on_bad_params => 0);

$sth->execute();
my $from = 'dan@hijinxcomics.com';
while(my $sub = $sth->fetchrow_hashref){
	my $to = $sub->{email};
	my $name = $sub->{name};
	my ($fname, $lname) = split (/ /,$name );
	$fname = ucfirst($fname);
	$lname = ucfirst($lname);
	my $credit = $sub->{credit};
	$subject_template->param(name => "$fname $lname", credit => $credit);
	my $subject = $subject_template->output();
	if (valid($to)){
		my $msg = new Mail::Send;
		$msg->set("From", $from );
		$msg->to($to);
		$msg->subject($subject);
		my $fh = $msg->open;
		$template->param(name => $fname, credit => $credit);
		print $fh $template->output();
		print $subject;
		$fh->close || warn "can't send message:$!";
	}else{
		print STDERR "$to is invalid\n";
	}
}

