#!/usr/bin/perl

use DBI;
use Mail::Mailer;
use Date::Calc qw (Today Delta_Days);

my $cust_id = shift;
my %headers;
my $mailer = new Mail::Mailer "testfile";
my $dbh = DBI->connect( "dbi:mysql:hijinx",  "hijinx", "passwerd");
my $sth = $dbh->prepare("select name, email, checkin from customers where id = ? and frozen = 0");
my $sth2 = $dbh->prepare("select distinct titles.name as title from titles, 
			customers, this_week, subscriptions where 
			subscriptions.title = titles.id and subscriptions.customer = customers.id
			 and customers.id = ? and subscriptions.title = this_week.id
			 and titles.archived = 0 order by title" );
my $gmt = gmtime();
my ($year, $month, $day) = Today($gmt);
$year =~ s/\d\d(\d\d)/$1/;
if ($month < 10){ $month = 0 . $month};
if ($day < 10){ $day = 0 . $day};
my $today = $year . $month . $day;




$sth->execute($cust_id);
$sth2->execute($cust_id);
my $customer = $sth->fetchrow_hashref;
my $delta = parse_date($customer->{"checkin"}, $today);
$headers{'To'} = $customer->{"email"}  ;
$headers{'From'} = 'bookbot@hijinxcomics.com';
$headers{'Subject'} = 'This week at Hijinx Comics [beta test]';
$mailer->open(\%headers);
print $mailer $customer->{"name"}, " $delta days\n";
while(my $sub = $sth2->fetchrow_hashref){
	print $mailer $sub->{"title"}, "\n";
}
$mailer->close;




sub parse_date{
        my $date1 = shift;
        my $date2 = shift;
        my ($year1, $month1, $day1) = date_split($date1);
        my($year2, $month2, $day2) = date_split($date2);
        my $Dd = Delta_Days($year1, $month1, $day1,$year2, $month2, $day2);
        return $Dd;
}
sub date_split($){
        my $date = shift;
        my $year = substr($date,0,2);
        my $month = substr($date,2,2);
        my $day = substr($date,4,2);
                if ($year){
                 return ($year,$month,$day);
                }else{
                        return (03,01,01)
                }
}

