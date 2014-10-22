#!/usr/bin/perl

use DBI;
my $dbh = DBI->connect( "dbi:mysql:hijinx@gal",  "hijinx", "passwerd") || die "no connect:$!\n" ;
print "get latest invoice file?:";
my $response = <>;
if ($response =~ /y/i){
	system ('scp heretic@vatican.com:/home/heretic/work/website/data/invoice.txt data/');
}
open (INVOICE, "data/invoice.txt") or die "can't open data/invoice.txt:$!";
my @oddballs;
my @issues;
my @tpbs;
while(<INVOICE>){
	my $issue;
	my($quantity,$diamond,$description,$price,$unit_cost, $inv_amt,$category) = split /,/;
	$description =~ s/\"//g;
	($title,$issue) = split (/\#/, $description);
	$title =~ s/^(.*)?\#.*?$/$1/;
	$title =~ s/\s*^//;#trim whitespace
	if($category == 1){ 
		push @issues, "$title:$issue:$quantity:$diamond";
	}elsif($category == 3){
		push @tpbs, "$title\n";
	}else{
		push @oddballs, "$title\n";
	}
}
#my @sorted_issues = sort(@issues);

my $sth = $dbh->prepare("select id from titles where name = ?" ) || die "no select:$!\n";
my $sth2 = $dbh->prepare("insert into this_week(id) values(?)" );
my $sth3 = $dbh->prepare("insert into titles values(?,?,0)") or die "cant prep 3";
my $sth4 = $dbh->prepare("update titles set name = ? where id = ?") or die "cant prep 4";
my $sth5 = $dbh->prepare("select order_qty from cycles where title_id = ? and issue = ?") || die "can't prep sth5:$!\n";
my $sth6 = $dbh->prepare("insert into cycles values(?,?,?,DATE_FORMAT(?, '%m/%d/%y'),
                                DATE_FORMAT(?, '%m/%d/%y'),?,?,?,?,?,?,?)" ) or die "can't prep";
my $sth7 = $dbh->prepare("update cycles set order_qty = order_qty + ?, rcv_qty = rcv_qty + ?,
						week_1 = week_1 + ?, week_2 = week_2 +?, 
						description = concat( description, ?) where  title_id = ? and issue = ?" ) 
						or die "can't prep 7:$!\n";



foreach my $title_issue_qty (@issues){
	my ($title, $issue, $qty, $diamond) = split (/:/, $title_issue_qty);
	$diamond =~ s/\"//g;
	$issue =~ s/^(\d*)?.*$/$1/;
	#$issue = ($issue +1); #uncomment to test
	my $status = $sth->execute($title);
	if ($status == 1) {
		my $id =  $sth->fetchrow_array, "\n";
		print  "$title \#$issue id:$id status:$status2\n";
		$sth2->execute($id);
		my $status2 = $sth5->execute($id,$issue)||warn "can't get cycle info:$!\n";
		if ($status2 != 1){
			print "new to me $title $issue\n";
			$sth6->execute($id, $issue, $qty, NULL, NULL,
                        $qty, $qty, $qty,NULL, NULL,  NULL, "$diamond")
                        or die "can't execute cycle insert:". $sth6->errstr;
	
		}else{
			print "not new $title $issue";
			print " appears to be a reorder, add qtys to existing cycle columns?:";
			my $answer = <>;
			if ($answer =~ /y/i){
				$diamond = $diamond . "updated";
				print $diamond. "\n";
				$sth7->execute( $qty, $qty, $qty, $qty, " r/o $qty" , $id, $issue) 
					or die "can't execute 7:$!\n";
			}
		}
	}else{
		print "can't find: $title\n";
		print "\t1) add and select it\n";
		print "\t2) add it & select another\n";
		print "\t3) change existing title\n";
		print "\t4) don't add, select another \n";
		print "\t5) ignore it \n";
		print "enter selection:";
		my $answer = <STDIN>;
		chomp $answer;
		if ($answer == 1){
			$sth3->execute(undef,$title);
			print "added $title\n";
			$sth->execute($title);
			my $id =  $sth->fetchrow_array, "\n";
			$sth2->execute($id);
			$sth6->execute($id, $issue, $qty, NULL, NULL,
                        $qty, $qty, $qty,NULL, NULL,  NULL, "$diamond")
                        or die "can't execute cycle insert:". $sth6->errstr;
		}elsif($answer == 2){
			$sth3->execute(undef,$title);
			print "added $title\n";
			$sth->execute($title);
			print "\nadditional id to select:";
			my $extra = <STDIN>;
			#chomp $extra;
			my $id =  $sth->fetchrow_array, "\n";
			$sth2->execute($id);
			$sth2->execute($extra);
			$sth6->execute($id, $issue, $qty, NULL, NULL,
                        $qty, $qty, $qty,NULL, NULL,  NULL, "$diamond")
                        or die "can't execute cycle insert:". $sth6->errstr;
			
		}elsif($answer == 3){
			print "\nid to change to $title:";
			my $newid = <STDIN>;
			chomp $newid;
			$sth4->execute($title,$newid);
			$sth6->execute($newid, $issue, $qty, NULL, NULL,
                        $qty, $qty, $qty,NULL, NULL,  NULL, "$diamond")
                        or die "can't execute cycle insert:". $sth6->errstr;
			$sth2->execute($newid);
			
		}elsif($answer == 4){
			print "\nid to select instead of  $title:";
			my $newid = <STDIN>;
			chomp $newid;
			$sth2->execute($newid);
			
		}else{
			print "ignoring $title\n";
		}
		
	}
	#print "\033[2J";

}



#print "########## COMICS #############\n\n", @sorted_issues;
print "\n\n######### GN/TPB #############\n\n", @tpbs;
print "\n\n######### other stuff #############\n\n", @oddballs;
