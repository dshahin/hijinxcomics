#!/usr/bin/perl

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Hijinx.pm
# Copyright (c) 2004 Daniel J Shahin
# All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License,
# Version 2, as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# Copies of the GNU General Public License are available from
# the Free Software Foundation website, http://www.gnu.org/.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

package Hijinx;

#use strict;
use base CGI::Application;
use base CGI::Application::Plugin::Session;
use CGI::Carp qw(fatalsToBrowser);
use HTML::Template;
use DBI;
use URI::Escape;
use Date::Calc qw(Today Delta_Days Add_Delta_YM);
use Email::Valid;
use Business::ISBN qw(ean_to_isbn is_valid_checksum);
#use Mail::Mailer;

sub setup {
    my $self = shift;
    $self->start_mode('today');
    $self->mode_param('rm');
    $self->run_modes(
        'list'                  => 'title_form',
        'login'                 => 'login',
        'today'                 => 'today',
        'checkin'               => 'checkin',
        'checkin_member'        => 'checkin_member',
        'logout'                => 'logout',
        'customer_info'         => 'customer_info',
        'member_info'           => 'member_info',
        'wish'                  => 'customer_info',
        'note'                  => 'member_info',
        'delete_note'           => 'member_info',
        'delete_note_today'     => 'delete_note_today',
        'add_credit'            => 'member_info',
        'use_credit'            => 'member_info',
        'delete_wish'           => 'customer_info',
        'customers'           => 'customers',
        'subs'                  => 'subscriptions',
        'week_subs'             => 'week_subs',
        'week_subs_by_cust'             => 'week_subs_by_cust',
        'cycle_worksheet'                => 'cycle_worksheet',
        'cycles'                => 'cycles',
        'archive'               => 'archive',
        'freeze'                => 'freeze',
        'unfreeze'              => 'unfreeze',
        'search'                => 'search',
        'books'                => 'books',
        'book_search'                => 'book_search',
        'edit_book_results'                => 'edit_book_results',
        'club_search'           => 'club_search',
        'detail'                => 'detail',
        'unarchive'             => 'unarchive',
        'stats'                 => 'stats',
        'this_week'             => 'this_week',
        'next_week'             => 'next_week',
        'last_week'             => 'next_week',
        'title_info'            => 'title_info',
        'clone_title'           => 'clone_title',
        'delete'                => 'unsubscribe',
        'chart'                 => 'chart',
        'list_customers'        => 'list_customers',
        'list_titles'           => 'list_titles',
        'add_customers'         => 'add_customers',
        'add_book_club_member'  => 'add_book_club_member',
        'add_title'             => 'add_title',
        'star_search'           => 'star_search',
        'add_customer'          => 'add_customer',
        'update_customer'       => 'update_customer',
        'update_member'         => 'update_member',
        'buy_book'              => 'member_info',
        'tag'                   => 'tag',
        'tag_info'                   => 'tag_info',
        'del_tag'                   => 'del_tag',
        'remove_tag'                   => 'remove_tag',
        'update_book'           => 'update_book',
        'update_title'          => 'update_title',
        'delete_title'          => 'delete_title',
        'remove_from_week'      => 'remove_from_week',
        'remove_from_last_week' => 'remove_from_last_week',
        'delete_customer'       => 'delete_customer',
        'delete_member'         => 'delete_member',
        'edit_subscriptions'    => 'title_form',
        'preview'               => 'show_preview',
        'subscribe'             => 'subscribe',
        'wishlists'             => 'wishlists',
        'add_next'              => 'add_next',
        'receive_invoice'       => 'receive_invoice',
        'confirm_invoice'       => 'confirm_invoice',
        'book_club'             => 'book_club',
        'orders'                => 'orders',
        'order_form'            => 'order_form',
        'list_order'            => 'list_order',
        'export_order'          => 'export_order',
        'drawers'               => 'drawers',
        'new_drawer'            => 'new_drawer',
        'close_drawer'          => 'close_drawer',
        'oic'                   => 'oic',
        'zip_graph'             => 'zip_graph',
        'graphs'                => 'graphs',
        'email'                 => 'email',
        'import_invoice'        => 'import_invoice',
        'import_books'        => 'import_books',
        'import_raw_isbn'        => 'import_raw_isbn',
        'view_invoice'          => 'view_invoice',
        'delete_invoice'        => 'delete_invoice',
        'ajax'                  => 'ajax',
        'multiply'              => 'multiply',
        'divide'                => 'divide',
        'ajax_rem_this_week'    => 'ajax_rem_this_week',
        'add_this_week'         => 'add_this_week',
        'add_d_note'            => 'add_d_note',
        'delete_d_note'         => 'delete_d_note',
        'rcv_inv'               => 'rcv_inv',
        'osd'                   => 'osd',
        'import_customers'                   => 'import_customers',
        'book_reorders'                   => 'book_reorders',
        'os_book_reorders'                   => 'outstanding_book_reorders',
        'sparkline'                   => 'sparkline',
        'multi'                   => 'multi',
        'changes'                   => 'changes',
        'cust_csv'                   => 'cust_csv',
        'books_csv'                   => 'books_csv',
        'bc_csv'                   => 'bc_csv',
        'top_gns'                   => 'top_gns',
        'report'                   => 'report',
        'search_comic_upc'                   => 'search_comic_upc',
        'update_single_cycle'                   => 'update_single_cycle',
        'book_email_list'                   => 'book_email_list',
    );

}

sub cgiapp_init {
    my $self = shift;
    my $q    = $self->query();
    my $rm   = $q->param('rm');
    $self->{dbh} = DBI->connect(
        $self->param('database'),
        $self->param('dbuser'),
        $self->param('dbpass')
      )
      || die "can't connect:$!";
    my $namor_db = $self->param('namor_db');
    if ($namor_db) {  
		$self->{namor_db} = DBI->connect($namor_db) || croak "can't open namor db";
    }
    my $dbh = $self->{dbh};
    CGI::Session->name( $self->param(storename) );
    $self->session_config(
        CGI_SESSION_OPTIONS => [ "driver:mysql", $q, { Handle => $dbh } ],
        COOKIE_PARAMS       => {
            -path    => '/',
            -name    => $self->param(storename),
            -expires => '+24h',
        },
        SEND_COOKIE => 1,
      )
      || die "can't get session:$!";
    my $session = $self->session();

    unless ( $rm eq 'chart'
        || $q->param('rm') eq 'zip_graph'
        || $q->param('rm') eq 'sparkline'
        || $q->param('rm') eq 'export_order'
        || $q->param('rm') eq 'multiply'
        || $q->param('mode') eq 'export'
        || $q->param('rm') eq 'cust_csv'
        || $q->param('rm') eq 'books_csv'
        || $q->param('rm') eq 'book_email_list'
        || $q->param('rm') eq 'bc_csv'
        || $q->param('rm') eq 'divide' )
    {
        print $self->session->header( $self->session->cookie );
    }
}

sub cgiapp_prerun {
    my $self     = shift;
    my $q        = $self->query();
    my $session  = $self->session();
    my $rm_perms = $self->{rm_perms};
    unless ( $self->session->param('~logged-in') ) {
        $self->prerun_mode('login');
    }
}

sub teardown {
    my $self = shift;
    my $dbh  = $self->{dbh};
    $dbh->disconnect;
}


sub zip_graph {
    use GD::Graph::pie;
    use GD::Graph::Data;
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $type = $q->param("type");
    my $sth;
    my $label = "comics subscribers by zip code";

    if ( $type eq "book_club" ) {
        $sth = $dbh->prepare(
            "select zip, count(zip) as count from book_club
			where zip > 0  group by zip order by count desc limit 200"
        );
        $label = "book club members by zip code";
    }
    elsif ( $type eq "frozen" ) {
        $sth = $dbh->prepare(
            "select zip, count(zip) as count from customers
			where frozen = 1 group by zip order by count desc"
        );
        $label = "frozen comic subscribers by zip code";
    }
    elsif ( $type eq "all_subs" ) {
        $sth = $dbh->prepare(
            "select zip, count(zip) as count from customers
			where zip > 0  group by zip order by count desc"
        );
        $label = "frozen and active comic subscribers by zip code";
    }
    else {
        $sth = $dbh->prepare(
            "select zip, count(zip) as count from customers
			where zip > 0 and frozen= 0 group by zip order by count desc"
        );
    }
    my @zips;
    my @counts;
    $sth->execute() or die "can't execute $!";
    unless ($sth->rows){
          #warn "less than 1 row in graph";
          push ( @zips, "no data");
          push ( @counts, 1);
    }else{
	    while ( my @slice = $sth->fetchrow_array ) {
		push @zips,   "$slice[0] ($slice[1])";
		push @counts, $slice[1];
	    }
    }
    my $graph = GD::Graph::pie->new( 500, 500 )
      or die "can't make new graph $!";
    $graph->set('3d' =>0 );
    $graph->set_title_font('/fonts/arial.ttf', 24);
    $data = [ \@zips, \@counts, \@counts ];
    $graph->set(
        x_label     => 'issue #',
        y_label     => 'copies ordered',
        title       => $label,
        show_values => \$data
    );
    my $gd = $graph->plot($data) or die "can't plot png $!";
    my $format = $graph->export_format;
    print $q->header( -type => "image/$format" );
    binmode STDOUT;
    print $gd->png();
    exit;

}

sub sparkline{
	use GD::Graph::sparklines;
    my $self     = shift;
    my $q        = $self->query();
    my $dbh      = $self->{dbh};
    my $title_id = $q->param("title_id") || die "must specify title id";
	$sth = $dbh->prepare("select  issue, (rcv_qty + reorder - week_2) as sold from    
						cycles where   title_id = ?  and 
						(rcv_qty + reorder - week_2)  > 0 order by    issue asc");
	$sth->execute($title_id) || die "can't execute";
	my (@issues, @sold);
	while (my $row = $sth->fetchrow_hashref){
  		push ( @issues, $row->{'issue'} );
  		push ( @sold, $row->{'sold'} );
  		$last = $row->{'sold'} ;
  		$issue = $row->{'issue'} ;
	}
	my $data = [ \@issues, \@sold ];
    	unless ($sth->rows){
          #warn "less than 1 row in graph";
          push ( @issues, 0);
          push ( @sold, 0);
	}
	my $graph = GD::Graph::sparklines->new(100, 30) or die "can't make graph $!";
    my $gd = $graph->plot($data) or die "can't plot png $!";
    my $format = $graph->export_format;
    print $q->header( -type => "image/$format" );
    binmode STDOUT;
    print $gd->png();
    exit;
	
	exit;
}

sub chart {
    use GD::Graph::linespoints;
    use GD::Graph::Data;
    my $self     = shift;
    my $q        = $self->query();
    my $dbh      = $self->{dbh};
    my $title_id = $q->param("title_id");
    my $limit    = $q->param("limit");
    my $sth;

    if ( $limit > 0 ) {
        $sth = $dbh->prepare(
            "select  issue, order_qty, week_1, week_2,
			 rcv_qty, reorder, subs  from cycles where title_id = ? 
			order by issue desc limit $limit ");
    }
    else {
        $sth = $dbh->prepare(
            "select  issue, order_qty, week_1, week_2,
			 rcv_qty, reorder, subs  from cycles where title_id = ? order by issue "
        );
    }
    $sth2 = $dbh->prepare("select name from titles where id = ?");
	$sth2->execute($title_id);
    my ($title) = $sth2->fetchrow_array;
    my @issues;
    my @orders;
    my @sales;
    my @subs;
    my @week1;
    my $max = 0;
    $sth->execute($title_id) or die "can't execute $!";
    unless ($sth->rows){
          #warn "less than 1 row in graph";
          push ( @issues, 0);
          push ( @orders, 0);
          push ( @sales, 0);
          push ( @subs, 0);
          push ( @week1, 0);
    }

    while ( my @cycle = $sth->fetchrow_array ) {
        if ( ( $cycle[4] + $cycle[5] ) > $max ) { $max = $cycle[4] + $cycle[5] }
        my $order   = $cycle[1];
        my $issue   = $cycle[0];
        my $week_1  = $cycle[2];
        my $week_2  = $cycle[3];
        my $rcv_qty = $cycle[4];
        my $reorder = $cycle[5];
        my $subs    = $cycle[6];
        my $sellthru;

        if ( $rcv_qty > 0 ) {
            $sellthru = ( $rcv_qty + $reorder - $week_2 );
        }
        else {
            $sellthru = 0;
        }

        push( @sales, $sellthru );
        push( @week1, ( $rcv_qty - $week_1 ) );
        push( @issues, $issue );
        push( @subs,   $subs );
        push( @orders, $rcv_qty + $reorder );
    }
    $max = $max + 10;
    my $num = @orders;
    my $data;
    my $label;
    if ( $limit > 0 ) {
        my @reverse_sales  = reverse @sales;
        my @reverse_week1  = reverse @week1;
        my @reverse_issues = reverse @issues;
        my @reverse_orders = reverse @orders;
        my @reverse_subs   = reverse @subs;
        $data = [
            \@reverse_issues, \@reverse_orders, \@reverse_sales,
            \@reverse_week1,  \@reverse_subs
        ];
        $label = "$title $limit months";
    }
    else {
        $data = [ \@issues, \@orders, \@sales, \@week1, \@subs ];
        $label = "$title life cycle";
    }

    my $graph;
    if ( $q->param("mini") == 1 ) {
        $graph = GD::Graph::linespoints->new( 200, 150 )
          or die "can't make new graph $!";
        $graph ->set_title_font(GD::gdTinyFont);
    }
    else {
        $graph = GD::Graph::linespoints->new( 400, 300 )
          or die "can't make mini graph $!";
    }
    $graph->set(
        x_label       => 'issue #',
        y_label       => 'copies ordered',
        title         => $label,
        y_tick_number => 1,
        y_min_value   => 0,
        y_max_value   => "$max",
        show_values   => \$data
    );
    my $gd = $graph->plot($data) or die "can't plot png $!";
    my $format = $graph->export_format;
    print $q->header( -type => "image/$format" );
    binmode STDOUT;
    print $gd->png();
    exit;

}

sub logout {
    my $self     = shift;
    my $q        = $self->query();
    my $session  = $self->session();
    my $template = $self->load_tmpl( 'logout.tmpl', cache => 1 );
    $self->session->param( '~logged-in', 0 );
    $self->session_delete;

    #warn $session->param( 'hijinx_name') . " logged out";
    print $template->output();
    exit;
}

sub star_search {
    my $self     = shift;
    my $q        = $self->query();
    my $dbh      = $self->{dbh};
    my $template = $self->load_tmpl( 'star_search.tmpl.html', cache => 1 );
    my $sth1 = $dbh->prepare("select * from star_items order by rand() limit 1")
      or die "cant prep rand";
    $sth1->execute() || die "can't select rand:$!";
    my $rand_item = $sth1->fetchrow_hashref() || die "can't get rand";

    if ( $q->param('search_term') ) {
        my $term = "\%" . $q->param('search_term') . "\%";
        my $sth  = $dbh->prepare(
            "select star, title, price from star_items 
				where title like ? order by title;"
          )
          || die "can't prep:$!";
        $sth->execute($term) || die "can't select titles:$!";
        my @titles;
        while ( my $title = $sth->fetchrow_hashref ) {
            push( @titles, $title );
        }
        my $results = @titles;
        $template->param(
            RESULTS => $results,
            MESSAGE => "results for <b>" . $q->param('search_term') . "</b>",
            TITLES  => \@titles
        );
    }
    else {
        $template->param(
            rand_code  => $rand_item->{star},
            rand_title => $rand_item->{title},
            MESSAGE    => "enter a search term"
        );
    }
    print $template->output();
    exit;
}

sub archive {
    my $self   = shift;
    my $q      = $self->query();
    my $letter = $q->param('letter') || 'a';
    my $dbh    = $self->{dbh};
    my $sth    = $dbh->prepare("update titles set archived = 1 where id = ?");
    $sth->execute( $q->param('title_id') ) || warn "can't execute";
    if ( $q->param("bm") eq "info" ) {
        $self->customer_info();
    }elsif( $q->param("bm") eq "title_info"){
        $self->title_info();
    }
    else {
        $q->param( -name => 'letter', -value => $letter );
        $self->list_titles();
    }
}

sub unarchive {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $sth  = $dbh->prepare("update titles set archived = 0 where id = ?");
    $sth->execute( $q->param('title_id') ) || warn "can't execute";
    if ( $q->param('bm') ) {
        my $bm =  $q->param('bm');
        if( $bm == 'title_info'){
		$self->title_info();
	}else{
	# archives
        $q->param( -name => 'show', -value => $bm );
	}
    }
    $q->param( -name => 'letter', -value => $letter );
    $self->list_titles();
}

sub freeze {
    my $self = shift;
    my $q    = $self->query();
    my $id   = $q->param('id');
    my $letter   = $q->param('letter');
    my $dbh  = $self->{dbh};
    my $sth  = $dbh->prepare("update customers set frozen = 1 where id = ?");
    my $sth2 = $dbh->prepare("i nsert into wishes values(NULL, $id, ?)");
    my $sth3 = $dbh->prepare("select name, email, checkin from customers where id = ?");
    $sth->execute($id) || warn "can't execute";
    my $freeze_date = `date`;
    chomp $freeze_date;
    $sth2->execute("frozen on $freeze_date") || warn "can't execute";
    $sth3->execute($id);
    my $customer = $sth3->fetchrow_hashref;
    my $name = $customer->{name};
    my $email = $customer->{email};
    my $checkin = $customer->{checkin};
    #warn ("name:$name email:$email last checkin:$checkin");
    $q->param( -name => 'letter', -value => $letter );
    $self->list_customers();
}

sub unfreeze {
    my $self = shift;
    my $q    = $self->query();
    my $id   = $q->param('id');
    my $letter   = $q->param('letter');
    my $dbh  = $self->{dbh};
    my $sth  = $dbh->prepare("update customers set frozen = 0 where id = ?");
    my $sth2 = $dbh->prepare("insert into wishes values(NULL, $id, ?)");
    $sth->execute($id) || warn "can't execute";
    my $freeze_date = `date`;
    chomp $freeze_date;
    $sth2->execute("unfrozen on $freeze_date") || warn "can't execute";
    $q->param( -name => 'letter', -value => $letter );
    $self->list_customers();
}

sub update_single_cycle{
    my $self   = shift;
    my $q      = $self->query();
    my $title_id = $q->param('title_id') || croak "must provide title_id" ;
    my $issue = $q->param('issue') || croak "must provide issue" ;
    my $new = $q->param('new') ;
    my $qty = $q->param('qty') ;
    my $dbh    = $self->{dbh};
    my $sth;
    if ($new){
    	$sth  = $dbh->prepare("update cycles set week_1 = ?,  week_2 = ? where title_id = ? and issue = ?");
	$sth->execute($qty,$qty,$title_id,$issue) || croak "can't execute" . $sth->errstr;
	#croak "new comic";
    }else{
    	$sth  = $dbh->prepare("update cycles set week_2 = ? where title_id = ? and issue = ?");
	$sth->execute($qty,$title_id,$issue) || croak "can't execute" . $sth->errstr;
	#croak "old comic";
    }
    $self->search_comic_upc;

}
sub search_comic_upc {
    my $self   = shift;
    my $q      = $self->query();
    my $dbh    = $self->{dbh};
    my $upc = $q->param('upc') ;
    chomp $upc;
    if ($upc =~ /\D/) {
        croak "UPC must contain only numerals";
    }
    my $sth  = $dbh->prepare("select invoices.descr as title, cycles.title_id as id, cycles.week_1 as week_1, cycles.week_2 as week_2, cycles.upc as upc, cycles.dcd as dcd, cycles.issue as issue from invoices, cycles where cycles.upc like ? and cycles.upc = invoices.upc ");
    $sth->execute($upc) || croak "can't execute " . $sth->errstr;
    my @issues;
    while (my $issue =  $sth->fetchrow_hashref){
        if ($self->is_new_comic($issue->{'id'})){
             $issue->{this}++;
	}
    	$issue->{prefix} = substr($issue->{dcd},0,5);
        push (@issues, $issue);
    }
    
    my $bookref = \@issues;
    my $template = $self->load_tmpl(
            'single_cycle.tmpl.html',
            cache             => 1,
            die_on_bad_params => 0
          ) or die "can't load template";
	$template->param( BOOKS             => $bookref,
			UPC => $upc);
    print $template->output() or die "foo";
	exit;
}
sub is_new_comic {
    my $self   = shift;
    my $title_id = shift || croak "must provide title_id";
    my $dbh    = $self->{dbh};
    my $sth = $dbh->prepare("select id from this_week where id = ? limit 1");
    $sth->execute($title_id) ||  croak "can't execute " .  $sth->errstr;
    my ($this) =  $sth->fetchrow_array;
    return $this;
}
sub list_titles {
    my $self   = shift;
    my $q      = $self->query();
    my $dbh    = $self->{dbh};
    my $letter = $q->param('letter') || 'a';
    my $sth;
    my $template_path;
    my $letterstring = "\%\%";
    if ( $q->param('show') eq 'all' ) {
        $letter = "*";
        $sth    =
          $dbh->prepare(
            "select name, id  from titles where name like ? order by name");
        $template_path = 'list_titles.tmpl.html';
    }
    if ( $q->param('show') eq 'all_active' ) {
        $letter = "*";
        $sth    =
          $dbh->prepare(
"select name, id  from titles where name like ? and archived = 0 order by name"
          );
        $template_path = 'list_titles.tmpl.html';
    }
    elsif ( $q->param('show') eq 'archives' ) {
        if ( length($letter) > 1 ) {
            $letterstring = "\%" . $letter . "\%";
            $sth          =
              $dbh->prepare(
"select name, id, archived  from titles where name like ? order by name"
              );
        }
        else {
            $letterstring = $letter . "\%";
            $sth          =
              $dbh->prepare(
"select name, id, archived  from titles where archived = 0 and name like ? order by name"
              );
        }
        $sth =
          $dbh->prepare(
"select name, id  from titles where archived = 1 and name like ? order by name"
          );
        $template_path = 'list_archives.tmpl.html';
    }
    else {
        if ( length($letter) > 1 ) {
            $letterstring = "\%" . $letter . "\%";
            $sth          =
              $dbh->prepare(
"select name, id, archived  from titles where name like ? order by name"
              );
        }
        else {
            $letterstring = $letter . "\%";
            $sth          =
              $dbh->prepare(
"select name, id, archived  from titles where archived = 0 and name like ? order by name"
              );
        }
        $template_path = 'list_titles.tmpl.html';
    }
    $sth->execute($letterstring) || die "can't select titles" . $sth->errstr();
    my $sth2 = $dbh->prepare("select count(customer) as sub_count from subscriptions, customers  where customers.id = subscriptions.customer and title = ? and customers.frozen=0") || croak "can't prep sth2" . $dbh->errstr();
    my @titles;
    while ( my $title = $sth->fetchrow_hashref ) {
	$sth2->execute($title->{'id'}) || croak "can't execute sub count" . $sth2->errstr();
	my ($subcount) = $sth2->fetchrow_array();
        $title->{'subcount'} = $subcount;
        $title->{'letter'} = $letter;
        push( @titles, $title );
    }
    my $total_titles = @titles;
    my $template     =
      $self->load_tmpl( $template_path, cache => 1, die_on_bad_params => 0, );
    $template->param(
        TITLES       => \@titles,
        TOTAL_TITLES => $total_titles,
        LETTER       => uc($letter)
    );
    $template->param( $self->session->param_hashref() );
    print $template->output();
    exit;
}

sub stats {
    my $self     = shift;
    my $q        = $self->query();
    my $dbh      = $self->{dbh};
    my $template = $self->load_tmpl( 'stats.tmpl.html', cache => 1 );
    my $sth      = $dbh->prepare(
        "select titles.name as name, titles.id as id, 
            count(subscriptions.customer) as count from subscriptions, 
            customers, titles where subscriptions.title = titles.id and 
            titles.archived=0 and subscriptions.customer = customers.id 
            and customers.frozen=0 group by titles.name order by count 
            desc, titles.name"
    );
    $sth->execute() || warn "can't select titles";
    my @titles;

    while ( my $title = $sth->fetchrow_hashref ) {
        push( @titles, $title );
    }
    my $total_titles = @titles;
    $template->param( TITLES => \@titles, TOTAL_TITLES => $total_titles );
    $template->param( $self->session->param_hashref() );

    print $template->output();
    exit;
}

sub list_customers {
    my $self   = shift;
    my $q      = $self->query();
    my $dbh    = $self->{dbh};
    my $letter = $q->param('letter') || 'a';
    my $letterstring;
    if ( length($letter) > 1 ) {
        $letterstring = "\%" . $letter . "\%";
    }
    else {
        $letterstring = $letter . "\%";
    }
    my $sth;
    my $template;
    if ( $q->param('show') eq 'frozen' ) {
        $sth =
          $dbh->prepare(
"select id, name, phone, zip from customers where name like ? and frozen = 1  order by name"
          );
        $template = $self->load_tmpl( 'list_frozen.tmpl.html', cache => 1, die_on_bad_params => 0 );
    }
    else {
        $sth =
          $dbh->prepare(
"select id, name, phone, zip, email from customers where name  like ? and frozen = 0  order by name"
          );
        $template = $self->load_tmpl( 'list_customers.tmpl.html', cache => 1, die_on_bad_params => 0 );
    }
    my $sth2 =
      $dbh->prepare(
"select checkin from customers where id = ? order by checkin desc limit 1"
      );
    my $today;
    if ( $q->param("date") ) {
        $today = $q->param("date");
    }
    else {
        $gmt = gmtime();
        my ( $year, $month, $day ) = Today($gmt);
        $year =~ s/\d\d(\d\d)/$1/;
        if ( $month < 10 ) { $month = 0 . $month }
        if ( $day < 10 )   { $day   = 0 . $day }
        $today = $year . $month . $day;
    }
    my @customers;
    $sth->execute($letterstring);
    while ( my $customer = $sth->fetchrow_hashref ) {
        $sth2->execute( $customer->{"id"} ) || die "can't get checkin: $!";
        my $checkin_ref = $sth2->fetchrow_hashref;
        my $delta;
        if ( $checkin_ref->{"checkin"} =~ /\-/ ) {
            $delta = $checkin_ref->{"checkin"};
            $delta =~ s/\-//g;
            my $checkin = substr( $delta, 2, 6 );
            $delta = parse_date( $checkin, $today );
        }
        else {
            $delta = parse_date( $checkin_ref->{"checkin"}, $today );
        }
        $customer->{"checkin"} = $delta;

        if ( $delta == 0 ) {
            $customer->{"status"} = "#FFFFFF";
        }
        elsif ( $delta <= 7 ) {
            $customer->{"status"} = "#33CC00";
        }
        elsif ( $delta <= 14 ) {
            $customer->{"status"} = "#FFFF00";
        }
        elsif ( $delta <= 21 ) {
            $customer->{"status"} = "#FF9900";
        }
        elsif ( $delta <= 30 ) {
            $customer->{"status"} = "#FF0000";
        }
        else {
            $customer->{"status"} = "#B1B1B1";
        }
	$customer->{"letter"} = $letter;
	$customer->{"longstorename"} = $self->session->param('longstorename');
        push( @customers, $customer );
    }
    my $total_customers = @customers;
    $template->param(
        CUSTOMERS       => \@customers,
	LONGSTORENAME => $self->session->param('longstorename'),
        TOTAL_CUSTOMERS => $total_customers
    );
    $template->param( $self->session->param_hashref() );
    unless ( $self->{headercheck} == 1 ) {

    }
    print $template->output();
    exit;
}

sub books_csv {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
	my $sth = 	$dbh->prepare("select * from books ");
	$sth->execute() || croak "can't select customers";
	my @books;
	while (my $book = $sth->fetchrow_hashref){
		foreach my $field (keys %$book){
			$book->{$field} =~ s/\t//g;
			$book->{$field} =~ s/\n//g;
			$book->{$field} =~ s/\r//g;
			#$book->{$field} =~ s/\(C:.*?\)//g;
			#$book->{$field} =~ s/\(MR\)//g;
		}
		push @books, $book;
	}
	$template = $self->load_tmpl( 'books_csv.tmpl', cache => 1, die_on_bad_params => 0 );
	$template->param(BOOKS => \@books);
    print $q->header( -type => 'text/plain' );
    print $template->output();
    exit;
	
}
sub cust_csv {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
	my $sth = 	$dbh->prepare("select id, email from customers where email != '' and frozen = 0  order by email");
	$sth->execute() || croak "can't select customers";
	my @customers;
	while (my $cust = $sth->fetchrow_hashref){
		chomp $cust->{'email'};
		$cust->{'email'} =~ s/\r//;
		#chop $cust->{'email'};
		push @customers, $cust;
	}
	$template = $self->load_tmpl( 'cust_csv.tmpl', cache => 1, die_on_bad_params => 0 );
	$template->param(CUSTOMERS => \@customers);
    print $q->header( -type => 'text/plain' );
    print $template->output();
    exit;
	
}

sub bc_csv {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
	my $sth = 	$dbh->prepare("select  distinct email from book_club where email !='' order by email");
	$sth->execute() || croak "can't select customers";
	my @customers;
	while (my $cust = $sth->fetchrow_hashref){
		$cust->{'email'} =~ s/\r//;
		push @customers, $cust;
	}
	$template = $self->load_tmpl( 'cust_csv.tmpl', cache => 1, die_on_bad_params => 0 );
	$template->param(CUSTOMERS => \@customers);
    print $q->header( -type => 'text/plain' );
    print $template->output();
    exit;
	
}

sub book_email_list{
    my $self = shift;
    my $q    = $self->query();
    my $isbn = $q->param('isbn') || croak "must provide isbn";
    my $dbh  = $self->{dbh};
	my $sth = 	$dbh->prepare("select book_club.email from book_club, notes where notes.isbn = ? and notes.customer_id = book_club.id and email != ''");
	$sth->execute($isbn) || croak "can't select customers";
	my @customers;
	while (my $cust = $sth->fetchrow_hashref){
		$cust->{'email'} =~ s/\r//;
		push @customers, $cust;
	}
	$template = $self->load_tmpl( 'cust_csv.tmpl', cache => 1, die_on_bad_params => 0 );
	$template->param(CUSTOMERS => \@customers);
    print $q->header( -type => 'text/plain' );
    print $template->output();
    exit;
}



sub book_club {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $sth;
    my $letter = $q->param('letter') || 'a';
    my $letterstring;
    if ( length($letter) > 1 ) {
        $letterstring = "\%" . $letter . "\%";
    }
    else {
        $letterstring = $letter . "\%";
    }
    my $template;
    $sth = $dbh->prepare(
        "select id, name, zip, email, credit from book_club where 
	name like ? order by name"
    );
    $template = $self->load_tmpl( 'book_club.tmpl.html', cache => 1, die_on_bad_params => 0 );
    my $sth2 =
      $dbh->prepare(
        "select sum(credit) as sum, avg(credit) as avg from book_club");

    my $today;
    if ( $q->param("date") ) {
        $today = $q->param("date");
    }
    else {
        $gmt = gmtime();
        my ( $year, $month, $day ) = Today($gmt);
        $year =~ s/\d\d(\d\d)/$1/;
        if ( $month < 10 ) { $month = 0 . $month }
        if ( $day < 10 )   { $day   = 0 . $day }
        $today = $year . $month . $day;
    }
    my @customers;
    $sth->execute($letterstring);
    $sth2->execute();
    my $credit_total;
    while ( my $credit = $sth2->fetchrow_hashref ) {
        $credit_total = $$credit{sum};
        $credit_avg   = $$credit{avg};
    }
    while ( my $customer = $sth->fetchrow_hashref ) {
        push( @customers, $customer );
    }
    my $total_customers = @customers;
    $template->param(
        CUSTOMERS       => \@customers,
        TOTAL_CUSTOMERS => $total_customers,
        TOTAL_CREDITS   => $credit_total,
        AVG_CREDITS     => $credit_avg
    );
    $template->param( $self->session->param_hashref() );
    print $template->output();
    exit;
}

sub add_customer {
    my $self         = shift;
    my $q            = $self->query();
    my $dbh          = $self->{dbh};
    my $new_customer = $q->param('new_customer') || croak "must provide customer name";
    my $email        = $q->param('email');
	if ($email) {
		Email::Valid->address($email) || croak "invalid email address: $email";
	}
    my $phone        = $q->param('phone');
    my $address          = $q->param('address');
    my $zip          = $q->param('zip');
    my $frozen       = 0;
    my $gmt          = gmtime();
    my ( $year, $month, $day ) = Today($gmt);
    $year =~ s/\d\d(\d\d)/$1/;
    if ( $month < 10 ) { $month = 0 . $month }
    if ( $day < 10 )   { $day   = 0 . $day }
    my $today = $year . $month . $day;
    my $sth   = $dbh->prepare("insert into customers values(?,?,?,?,?,?,?,?)") or die "cant prep";
    $sth->execute( undef, $new_customer, $email, $phone, $today, $frozen, $zip, $address )
      || die "can't insert new customer:" . $sth->errstr;
    my $namor = $self->{namor_db};
    if ($email && $namor){
		$self->update_namor($email);
	}
    $q->param( -name => 'letter', -value => $new_customer );
    $self->list_customers();
    exit;
}



sub update_namor {
	my $self = shift;
	my $email = shift || croak ("must provide valid email");
	my $dbh = $self->{dbh};
	my $namor = $self->{namor_db};
	my $sth1 = $dbh->prepare("select id, email from customers where email = ?");
	my $sth2 = $namor->prepare("insert or ignore into passwd values (?,?,?,?)");
	$sth1->execute($email) ||  die "can't execute" .  $sth1->errstr;
	$namor->do("begin");
	while (my $cust = $sth1->fetchrow_hashref()){
		#print $cust->{'email'} . "\n";
		my $invite = rand_invite();
		$sth2->execute($cust->{'id'},$cust->{'email'},'nopass',$invite) || die "can't execute: " . $sth2->errstr;
	}
	$namor->do("end");
	return;
}
sub rand_invite {
	@chars = ("A" .. "Z", "a" .. "z", 0 .. 9);
	$invite = join ("", @chars[map{ rand @chars} (1 .. 30)]);
	return $invite;
}

sub add_book_club_member {
    my $self         = shift;
    my $q            = $self->query();
    my $dbh          = $self->{dbh};
    my $new_customer = $q->param('new_customer');
    my $email        = $q->param('email');
    my $phone        = $q->param('phone');
    my $zip          = $q->param('zip');
    my $address          = $q->param('address');
    my $credit       = $q->param('credit');
    my $frozen       = 0;
    my $sth = $dbh->prepare("insert into book_club values(?,?,?,?,?,?,?,?,?)")
      or die "cant prep";
    $sth->execute( undef, $new_customer, $email, $phone, undef, $frozen, $zip,
        $credit, $address )
      || die "can't insert new customer:" . $sth->errstr;
    $q->param( -name => 'letter', -value => $new_customer );
    $self->book_club();
    exit;
}

sub update_customer {
    my $self  = shift;
    my $q     = $self->query();
    my $dbh   = $self->{dbh};
    my $namor   = $self->{namor_db};
    my $id    = $q->param('id');
    my $name  = $q->param('name');
    my $email = $q->param('email');
    my $phone = $q->param('phone');
    my $zip   = $q->param('zip');
    my $address   = $q->param('address');
    my $sth   =
      $dbh->prepare(
        "update customers set name=?, email=?, phone=?, zip=?, address=? where id=?")
      or die "cant prep";
    	$sth->execute( $name, $email, $phone, $zip, $address, $id )
      || die "can't insert new title:" . $sth->errstr;
    if($namor){
	my $sth3 = $namor->prepare("select login from passwd where id = ?");
	$sth3->execute($id);
	my $rs = $sth3->fetchrow_hashref;
	if ($sth3->rows){
    		my $sth2 = $namor->prepare("update passwd set login = ? where id = ?");
    		$sth2->execute($email, $id);
	}else{
		$self->update_namor($email);
	}
    }
    $self->customer_info();
    exit;
}

sub update_member {
    my $self  = shift;
    my $q     = $self->query();
    my $dbh   = $self->{dbh};
    my $id    = $q->param('id');
    my $name  = $q->param('name');
    my $email = $q->param('email');
    my $phone = $q->param('phone');
    my $zip   = $q->param('zip');
    my $address   = $q->param('address');
    my $sth   =
      $dbh->prepare(
        "update book_club set name=?, email=?, phone=?, zip=?, address=?  where id=?")
      or die "cant prep";
    $sth->execute( $name, $email, $phone, $zip, $address,  $id )
      || die "can't update book club member info" . $sth->errstr;
    $self->member_info();
    exit;
}

sub update_title {
    my $self     = shift;
    my $q        = $self->query();
    my $dbh      = $self->{dbh};
    my $title_id = $q->param('title_id');
    my $title    = $q->param('title');
    my $sth      = $dbh->prepare("update titles set name=? where id=?")
      or die "cant prep";
    $sth->execute( $title, $title_id )
      || die "can't insert new title:" . $sth->errstr;
    $self->title_info();
    exit;
}

sub add_title {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    if ( $q->param('new_title') ) {
        my $new_title = uc( $q->param('new_title') );
        my $sth       = $dbh->prepare("insert into titles values(?,?,0)")
          or die "cant prep";
        $sth->execute( undef, $new_title )
          || warn "can't insert new title:" . $sth->errstr;
        $self->list_titles();
        exit;
    }
    my $template = $self->load_tmpl( 'add_title.tmpl.html', cache => 1 , die_on_bad_params => 0);
    print $template->output();
    exit;
}

sub delete_customer {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $namor = $self->{namor_db};
    if ( $q->param('id') ) {
        my $id  = uc( $q->param('id') );
        my $sth = $dbh->prepare("delete from customers where id = ?")
          or die "cant prep";
        my $sth2 = $dbh->prepare("delete from subscriptions where customer = ?")
          or die "cant prep";
        my $sth3 = $dbh->prepare("delete from wishes where customer_id = ?") or die "cant prep";
    	if($namor){
        	my $sth4 = $namor->prepare("delete from passwd where id = ?") or warn "cant prep";
        	my $sth5 = $namor->prepare("delete from changes where customer = ?") or warn "cant prep";
        	$sth4->execute($id) || warn "can't delete namor";
        	$sth5->execute($id) || warn "can't delete  for namor:";
    	}
        $sth->execute($id)  || die "can't delete customer:";
        $sth2->execute($id) || die "can't delete subscriptions for customer:";
        $sth3->execute($id) || die "can't delete wishes for customer:";
        $self->list_customers();
        exit;
    }
    $self->list_customers();
    exit;
}

sub delete_member {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    if ( $q->param('id') ) {
        my $id  = uc( $q->param('id') );
        my $sth = $dbh->prepare("delete from book_club where id = ?")
          or die "cant prep";
        my $sth2 = $dbh->prepare("delete from notes where customer_id = ?")
          or die "cant prep";
        $sth->execute($id)  || die "can't delete member:";
        $sth2->execute($id) || die "can't delete member notes:";
        $self->book_club();
        exit;
    }
    $self->book_club();
    exit;
}

sub delete_invoice {
    my $self       = shift;
    my $q          = $self->query();
    my $dbh        = $self->{dbh};
    my $invoice_id = $q->param('invoice_id');
    my $sth        = $dbh->prepare("delete from invoices where invoice_id = ?")
      or die "cant prep";
    $sth->execute($invoice_id) || die "can't delete invoice:";
    $self->orders();
    exit;
}

sub delete_d_note {
    my $self  = shift;
    my $q     = $self->query();
    my $dbh   = $self->{dbh};
    my $d_id  = $q->param('d_id');
    my $today = $q->param('today');
    my $sth   = $dbh->prepare("delete from d_notes where id = ?");
    $sth->execute($d_id);
    $q->param( -name => 'date', -value => $today );
    $self->today();

}

sub add_d_note {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $sth  = $dbh->prepare("insert into d_notes values(?,?,?,?)");
    my $note = $q->param('d_note');
    $note =~ s/\n/<br>/g;
    my $today  = $q->param('today');
    my $emp_id = $self->session->param('hid');
    $sth->execute( NULL, $today, $note, $emp_id )
      || die "can't execute:" . $sth->errstr;
    $q->param( -name => 'date', -value => $today );
    $self->today();
}

sub wishlists {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $sth  = $dbh->prepare(
        "select customers.id as id, customers.name as customer, 
				wishes.wish as wish from customers, wishes where 
				customers.id = wishes.customer_id order by customer, wish"
    );
    $sth->execute();
    my @wishes;
    while ( my $wish = $sth->fetchrow_hashref ) {
        push( @wishes, $wish );
    }
    my $template = $self->load_tmpl( 'wishlists.tmpl.html', cache => 1 );
    $template->param( WISHES => \@wishes );
    print $template->output();
    exit;

}

sub delete_title {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    if ( $q->param('title_id') ) {
        my $title_id = uc( $q->param('title_id') );
        my $sth      = $dbh->prepare("delete from titles where id = ?")
          or die "cant prep";
        my $sth2 = $dbh->prepare("delete from subscriptions where title = ?")
          or die "cant prep";
        my $sth3 = $dbh->prepare("delete from cycles where title_id = ?")
          or die "cant prep";
        $sth->execute($title_id) || die "can't delete title:";
        $sth2->execute($title_id)
          || die "can't delete subscriptions for title:";
        $sth3->execute($title_id)
          || die "can't delete subscriptions for title:";
        my $letter = $q->param('letter') || 'a';
        $q->param( -name => 'letter', -value => $letter );
        $self->list_titles();
        exit;
    }
    $self->list_titles();
    exit;
}

sub remove_from_last_week {
    my $self       = shift;
    my $q          = $self->query();
    my $dbh        = $self->{dbh};
    my $week_table = "next_week";
    if ( $q->param('week_num') ) {
        my $num = $q->param('week_num');
        $week_table = "next_week_$num";
    }
    if ( $q->param('title_id') ) {
        my $title_id = uc( $q->param('title_id') );
        my $sth      = $dbh->prepare("delete from $week_table where id = ?")
          or die "cant prep";
        $sth->execute($title_id) || die "can't delete title:";
        $self->next_week();
        exit;
    }
    $self->this_week();
    exit;
}

sub remove_from_week {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    if ( $q->param('title_id') ) {
        my $title_id = uc( $q->param('title_id') );
        my $sth      = $dbh->prepare("delete from this_week where id = ?")
          or die "cant prep";
        $sth->execute($title_id) || die "can't delete title:";
        $self->this_week();
        exit;
    }
    $self->this_week();
    exit;
}

sub add_this_week {
    my $self     = shift;
    my $q        = $self->query();
    my $dbh      = $self->{dbh};
    my $week_num = $q->param('week_num') || 0;
    if ( $q->param('title_id') ) {
        my $title_id = uc( $q->param('title_id') );
        my $sth;
        if ( $week_num == 0 ) {
            $sth = $dbh->prepare("insert into this_week values(?)")
              or die "cant prep";
            $sth->execute($title_id) || die "can't add to this week:";
            $self->this_week();
            exit;
        }
        elsif ( $week_num == 1 ) {
            $sth = $dbh->prepare("insert into next_week values(?)")
              or die "cant prep";
            $sth->execute($title_id) || die "can't add to this week:";
            $q->param( -name => 'week_num', -value => 0 );
            $self->next_week();
            exit;
        }
        elsif ( $week_num > 1 ) {
            $sth = $dbh->prepare("insert into next_week_$week_num values(?)")
              or die "cant prep";
            $sth->execute($title_id) || die "can't add to this week:";
            $q->param( -name => 'week_num', -value => $week_num );
            $self->next_week();
            exit;
        }
    }
    exit;
}

sub add_next {
    my $self     = shift;
    my $q        = $self->query();
    my $dbh      = $self->{dbh};
    my $title_id = uc( $q->param('title_id') );
    my $sth      =
      $dbh->prepare(
"insert into next_week select distinct * from this_week where this_week.id > 0"
      )
      or die "cant prep";
    $sth->execute() || die "can't move titles:";
    $self->next_week();
    exit;
}

sub login {
    my $self    = shift;
    my $q       = $self->query();
    my $dbh     = $self->{dbh};
    my $session = $self->session();
    if ( $q->param('login') && $q->param('pass') && $q->param('agree') ) {
        my $sth =
          $dbh->prepare(
                "select pass, perm_level, id as hid from passwd where login=\""
              . $q->param('login')
              . "\"" );
        $sth->execute();
        my ( $pass, $perm_level, $id ) = $sth->fetchrow_array;

        if ( ( $pass ne '' ) && ( $pass eq $q->param('pass') ) ) {

            $self->{headercheck} = 1;
            $self->session->param( '~logged-in', 1 );
            $self->session->param( 'perm_level', $perm_level );
            $self->session->param( 'store_name', $self->param(storename) );
            $self->session->param( 'longstorename', $self->param(longstorename) );
            $self->session->param( 'default_credit', $self->param(default_credit) );
            #$self->session->param( 'gcode', $self->param(gcode) );

            $self->session->param( 'hid', $id )
              || die "can't set session param logged in";
            my $hname = $q->param('login');
            $session->param( 'hijinx_name', $hname );
            $self->today();
            exit;
        }
        else {
            my $template = $self->load_tmpl( 'login.tmpl', cache => 1 );
            print $template->output();
            exit;
        }

    }
    else {
        my $template = $self->load_tmpl( 'login.tmpl', cache => 1 );

        print $template->output();
        exit;
    }
    exit;
}

sub subscribe {
    my $self     = shift;
    my $q        = $self->query();
    my $id       = $q->param('id');
    my $title_id = $q->param('title_id');
    my $dbh      = $self->{dbh};
    my $sth      = $dbh->prepare("insert into subscriptions values(?,?)")
      or die "cant prep 4";
    $sth->execute( $title_id, $id );
    $self->title_form();
    exit;

}

sub title_form {
    my $self   = shift;
    my $q      = $self->query();
    my $id     = $q->param('id') || shift;
    my $dbh    = $self->{dbh};
    my $letter = $q->param('letter') || 'a';
    if ( length($letter) > 1 ) {
        $letterstring = "\%" . $letter . "\%";
    }
    else {
        $letterstring = $letter . "\%";
    }
    my $sth =
      $dbh->prepare(
        "select * from titles where archived = 0 and name like ? order by name"
      );
    $sth->execute($letterstring);
    my $sth2 = $dbh->prepare("select name from customers where id=\"$id\"");
    $sth2->execute() or die "barf:$!";
    my ($customer) = $sth2->fetchrow_array
      or carp "barf can't fetch id for $id $!";
    my $sth3 = $dbh->prepare(
        "select title from subscriptions, titles, customers
			  where customers.id = subscriptions.customer and 
			titles.id = subscriptions.title and titles.archived = 0 and 
			customers.id = ? "
      )
      or die "can't prepare";
    $sth3->execute($id) or die "can't execute 3:$!";
    my @subscriptions;

    while ( my ($subscription) = $sth3->fetchrow_array ) {
        push( @subscriptions, $subscription );
    }
    my $sth4 = $dbh->prepare("insert into subscriptions values(?,?)")
      or die "cant prep 4";
    my @rows;
    while ( my $hash_ref = $sth->fetchrow_hashref ) {
        $hash_ref->{letter} = $letter;
        my $title_id = $hash_ref->{id};
        if ( $q->param( "title_" . $title_id ) eq "on" ) {
            $hash_ref->{checked} = "checked";
            $sth4->execute( $title_id, $id );
            my $flag;

        }
        foreach my $title_id (@subscriptions) {
            if ( $hash_ref->{id} == $title_id ) {
                $hash_ref->{checked} = "checked";
            }
        }
        $hash_ref->{user_id} = $id;
        push @rows, $hash_ref;
    }
    my @new_subscriptions;
    $sth3->execute() or die "can't execute 3:$!";
    while ( my ($subscription) = $sth3->fetchrow_array ) {
        push( @new_subscriptions, $subscription );
    }
    my $template =
      $self->load_tmpl( 'titles.tmpl', cache => 1, die_on_bad_params => 0 )
      or die "can't load template";
    $template->param( COMICS => \@rows );
    my $length = @new_subscriptions;
    $template->param( login          => $customer );
    $template->param( letter         => $letter );
    $template->param( id             => $id );
    $template->param( number_of_subs => $length );
    $template->param( $self->session->param_hashref() );
    print $template->output() or die "foo";
    exit;
}

sub this_week {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $sth  =
      $dbh->prepare("select * from titles where archived = 0 order by name");
    my $sth3 = $dbh->prepare("insert into this_week values(?)");
    my $sth4 =
      $dbh->prepare(
"select issue from cycles where title_id = ? order by issue desc limit 1"
      );
    my $sth5 =
      $dbh->prepare(
"select date, invoice_id, dcd_cust_id, sum(inv_amt) as inv_total from invoices group by invoice_id order by date desc, dcd_cust_id asc limit 6"
      );
    $sth5->execute() || die "can't get invoices";
    my @invoices;

    while ( my $invoice = $sth5->fetchrow_hashref ) {
        push @invoices, $invoice;
    }

    if ( $q->param("delete_week") == 1 ) {
        $dbh->do("delete from this_week where id > 0");
    }
    my @subscriptions;
    my @rows;
    my @week;

    my $sth2 =
      $dbh->prepare(
"select distinct titles.name as name, this_week.id as id from titles, this_week where titles.id = this_week.id order by name"
      );
    $sth2->execute();

    while ( my $hash_ref = $sth2->fetchrow_hashref ) {
        $sth4->execute( $hash_ref->{id} )
          or die "can't execute:" . $sth4->errstr;
        my %week;
        $week{"name"} = $hash_ref->{name};
        $week{"id"}   = $hash_ref->{id};
        my @subs = $sth4->fetchrow_array;
        $week{"subs"} = $subs[0];
        push @week, \%week;
    }
    my @new_subscriptions;
    my $template = $self->load_tmpl(
        'this_week.tmpl.html',
        cache             => 1,
        die_on_bad_params => 0
      )
      or die "can't load template";
    $template->param(
        INVOICES  => \@invoices,
        COMICS    => \@rows,
        THIS_WEEK => \@week
    );
    $template->param( $self->session->param_hashref() );
    my $length = @new_subscriptions;
    print $template->output() or die "foo";
    exit;
}

sub next_week {
    my $self = shift;
    my $q    = $self->query();
    my $week_num;
    my $week_table;
    if ( $q->param("week_num") ) {
        $week_num   = $q->param("week_num");
        $week_table = "next_week_$week_num";
    }
    else {
        $week_table = "next_week";
    }
    my $dbh = $self->{dbh};

    #my $sth =
    #$dbh->prepare("select * from titles where archived = 0 order by name");
    my $sth3 = $dbh->prepare("insert into $week_table values(?)");
    my $sth4 =
      $dbh->prepare(
        "select count(*) from subscriptions where subscriptions.title = ?");
    if ( $q->param("delete_week") == 1 ) {
        $dbh->do("delete from $week_table where id > 0");
    }

    #$sth->execute();
    my @subscriptions;
    my @rows;
    my @week;

    #while ( my $hash_ref = $sth->fetchrow_hashref ) {
    #my %week;
    #my $title_id = $hash_ref->{id};
    #if ( $q->param( "title_" . $title_id ) eq "on" ) {
    #$sth3->execute($title_id) or die "can't execute:" . $sth3->errstr;
    #}
    #push @rows, $hash_ref;
    #}
    my $sth2 =
      $dbh->prepare(
"select distinct titles.name as name, $week_table.id as id from titles, $week_table where titles.id = $week_table.id order by name"
      );
    $sth2->execute();

    while ( my $hash_ref = $sth2->fetchrow_hashref ) {
        $sth4->execute( $hash_ref->{id} )
          or die "can't execute:" . $sth4->errstr;
        my %week;
        $week{"name"} = $hash_ref->{name};
        $week{"num"}  = $week_num;
        $week{"id"}   = $hash_ref->{id};
        my @subs = $sth4->fetchrow_array;
        $week{"subs"} = $subs[0];
        push @week, \%week;
    }
    my @new_subscriptions;
    my $template;
    if ( $q->param("cycle_worksheet") ) {
        $template = $self->load_tmpl(
            'cycle_worksheet.tmpl.html',
            cache             => 1,
            die_on_bad_params => 0
          )
          or die "can't load template";
    }
    else {
        $template = $self->load_tmpl(
            'next_week.tmpl.html',
            cache             => 1,
            die_on_bad_params => 0
          )
          or die "can't load template";
    }
    $template->param(
        COMICS    => \@rows,
        NEXT_WEEK => \@week,
        WEEK_NUM  => $week_num
    );
    $template->param( $self->session->param_hashref() );
    my $length = @new_subscriptions;
    print $template->output() or die "foo";
    exit;
}
sub cycle_worksheet {
    my $self     = shift;
    my $dbh      = $self->{dbh};
    my $q        = $self->query();
    my $week       = $q->param("week") || 'this';
	if ($week eq 'this'){
		
	}else{
		croak "don't know that week yet";
	}
	
	$sth = $dbh->prepare("select distinct id from this_week where id > 0");
	$sth2 = $dbh->prepare("select distinct id from next_week where id > 0");
	$sth3 = $dbh->prepare("select distinct id from next_week_2 where id > 0");
	$sth4 = $dbh->prepare("select distinct id from next_week_3 where id > 0");
    my %titles;
    my %this_week;
	$sth->execute();
	$sth2->execute();
	$sth3->execute();
	$sth4->execute();
	while(my ($c) = $sth->fetchrow_array){ 
		$titles{$c}++; 
		$this_week{$c}++; 
	};
	while(my ($c) = $sth2->fetchrow_array){ $titles{$c}++; };
	while(my ($c) = $sth3->fetchrow_array){ $titles{$c}++; };
	while(my ($c) = $sth4->fetchrow_array){ $titles{$c}++; };
	my @distinct_titles = keys(%titles);
	$sth6 = $dbh->prepare("select name from titles where id = ?");
	$sth7 = $dbh->prepare("select issue, week_2 from cycles where title_id = ? order by issue desc limit 6");
	my @books;
	foreach my $id (@distinct_titles){
		my (%comic, @issues);;
		$sth6->execute($id);
		$sth7->execute($id);
		($comic{'title'}) = $sth6->fetchrow_array;
		$comic{'id'} = $id;
		while (my $issue = $sth7->fetchrow_hashref){
			if ($this_week{$id}){
				$comic{'this_week'}++;
			}
			push @issues, $issue;
		}
		$comic{'issues'} = \@issues;
		push @books, \%comic;
	}
	use Data::Dumper;
	#croak  Dumper($books);
	@sorted  = sort { $a->{'title'} cmp $b->{'title'}} @books;
	#croak Dumper(@books);
	$bookref = \@sorted;
    my $template = $self->load_tmpl(
            'cycle_worksheet.tmpl.html',
            cache             => 1,
            die_on_bad_params => 0
          ) or die "can't load template";
	$template->param( BOOKS             => $bookref);
    print $template->output() or die "foo";
	exit;
}

sub cycles {
    my $self     = shift;
    my $dbh      = $self->{dbh};
    my $q        = $self->query();
    my $id       = $q->param("title_id");
    my $title_id = $q->param("title_id");
    my $issue    = $q->param("issue");
    my $reorder  = $q->param("reorder");

    #my $order_qty = $q->param("order_qty");
    my $order_date  = $q->param("order_date");
    my $rcv_date    = $q->param("rcv_date");
    my $rcv_qty     = $q->param("rcv_qty");
    my $week_1      = $q->param("week_1");
    my $week_2      = $q->param("week_2");
    my $description = $q->param("description");
    my $limit       = 6;
    my $subs;
    my $sth3 =
      $dbh->prepare(
"select count(customer) as subs from subscriptions, customers where customers.frozen = 0 and  title= ? and subscriptions.customer = customers.id"
      )
      or die "can't prep";
    $sth3->execute($title_id);
    $row  = $sth3->fetchrow_hashref() or die "can't fetch: " . $sth->errstr;
    $subs = $row->{subs};

    if ( $q->param("new") &&  $q->param("issue") ) {

        my $sth = $dbh->prepare(
            "insert into cycles values(?,?,?,DATE_FORMAT(?, '%m/%d/%y'),
			DATE_FORMAT(?, '%m/%d/%y'),?,?,?,?,?,?,?,NULL,?,NULL)"
          )
          or die "can't prep";
        $sth->execute(
            $title_id, $issue,       0,       $order_date, $rcv_date,
            $rcv_qty,  $week_1,      $week_2, $week_3,     $week_4,
            $reorder,  $description, $subs
          )
          or die "can't execute:" . $sth->errstr;

    }
    elsif ( $q->param("delete_issue_cycle") ) {
        my $issue = $q->param("issue");
        my $sth   =
          $dbh->prepare("delete from cycles where title_id = ? and issue = ?")
          or die "can't prep";
        $sth->execute( $id, $issue );

    }
    elsif ( $q->param("update_issue_cycle") ) {

        my $sth = $dbh->prepare(
            "update cycles set title_id = ?,
				issue = ?,  order_date = DATE_FORMAT(?,'%m/%d/%y'),
				rcv_date =  DATE_FORMAT(?,'%m/%d/%y'), rcv_qty = ?, week_1 = ?,
				week_2 = ?, reorder = ?, description = ?
				where  title_id = ? and issue = ?"
          )
          or die "can't prep";
        $sth->execute(
            $title_id,    $issue,  $order_date, $rcv_date,
            $rcv_qty,     $week_1, $week_2,     $reorder,
            $description, $id,     $issue,
          )
          or die "cant update" . $sth->errstr;

    }
    my $sth = $dbh->prepare("select name from titles where id=?")
      or die "can't prep";
    my $sth2;
    if ( $q->param("limit") ) {
        $limit = $q->param("limit");
        $sth2  = $dbh->prepare(
            "select title_id, issue, 
			 rcv_qty, reorder, week_1, week_2,  description, dcd, subs
			from cycles where title_id=? order by issue desc limit $limit"
        );
    }
    else {
        $sth2 = $dbh->prepare(
            "select title_id, issue, 
                         rcv_qty, reorder, week_1, week_2, description, dcd, subs
                        from cycles where title_id=? order by issue desc limit 6"
        );
    }
    $sth->execute($id)  or die "can't execute :$!";
    $sth2->execute($id) or die "can't execute :$!";
    my ($title) = $sth->fetchrow_array() or die "can't fetch: " . $sth->errstr;
    my $template = $self->load_tmpl(
        'cycles.tmpl.html',
        cache             => 1,
        loop_context_vars             => 1,
        die_on_bad_params => 0
    );
    my @cycles;
    my $bought       = 0;
    my $left         = 0;
    my $latest_issue = 0;

    while ( my $cycle = $sth2->fetchrow_hashref ) {
        if ( $cycle->{issue} > $latest_issue ) {
            $latest_issue = $cycle->{issue};
        }
        my $best = ( $cycle->{week_1} + $cycle->{week_2} );
        my $subs = $cycle->{subs};
        foreach my $stat ( $cycle->{week_1}, $cycle->{week_2} ) {
            $best = $stat

        }
        my $total_qty = $cycle->{rcv_qty} + $cycle->{reorder};
        my $sell_thru = 0;
        unless ( $total_qty == 0 ) {
            $sell_thru = ( 100 * ( ( $total_qty - $best ) / $total_qty ) );
        }
        if ( ( $total_qty - $best ) > 0 ) {
            $cycle->{sub_percentage} =
              substr( ( 100 * ( $subs / $total_qty ) ), 0, 5 );
        }
        $bought += $total_qty;
        $left   += $cycle->{week_2};
        $cycle->{sell_thru_percentage} = substr( $sell_thru, 0, 5 );
        $cycle->{sell_thru}            = ( $total_qty - $best );
        $cycle->{limit}                = ($limit);
        $cycle->{subs}                 = ($subs);
        push( @cycles, $cycle );
    }
    my $avg_sell_thru;
    my $since = ( $latest_issue - $limit );
    if ( $since < 0 ) { $since = 0 }
    my $sth4 =
      $dbh->prepare(
"select avg(rcv_qty + reorder  - week_2) as avg_sold, std((rcv_qty + reorder) - week_2) as std from cycles where title_id = ? and issue > ?"
      );
    $sth4->execute( $id, $since ) or die "can't execute :$!";
    my ( $avg_sold, $std ) = $sth4->fetchrow_array()
      or die "can't fetch: " . $sth->errstr;
    if ( $bought > 0 ) {
        $avg_sell_thru =
          substr( ( 100 * ( $bought - $left ) / $bought ), 0, 5 );
    }
    $template->param(
        CYCLES   => \@cycles,
        title    => $title,
        title_id => $id,
        limit    => $limit,
        avg      => $avg_sell_thru,
        avg_sold => $avg_sold,
        std      => $std
    );
    $template->param( $self->session->param_hashref() );
    print $template->output();
    exit;

}

sub customer_info {
    my $self = shift;
    my $dbh  = $self->{dbh};
    my $q    = $self->query();
    my $id   = $q->param("id");
    my $wish = $q->param("wish");
    if ( $q->param("rm") eq "wish" ) {
        my $sth5 = $dbh->prepare("insert into wishes values(NULL, $id, ?)");
        $sth5->execute($wish);
    }
    elsif ( $q->param("rm") eq "delete_wish" ) {
        my $wish_id = $q->param("wish_id");
        my $sth6    = $dbh->prepare("delete from wishes where id = ?");
        $sth6->execute($wish_id);
    }
    my $template = $self->load_tmpl( 'customer_info.tmpl.html', cache => 1 );

    my $sth2 =
      $dbh->prepare(
        "select name, email, phone, zip, address from customers where id=\"$id\"");
    $sth2->execute();
    my $sth3 = $dbh->prepare("select distinct id from this_week");
    $sth3->execute();
    my @books;
    my $sth4 =
      $dbh->prepare(
"select wish, id as wish_id from wishes where customer_id=\"$id\"order by wish_id"
      );
    $sth4->execute();

    while ( my $title = $sth3->fetchrow_hashref ) {
        push @books, $title->{id};
    }
    my ( $customer, $email, $phone, $zip, $address ) = $sth2->fetchrow_array;

    my $statement =
"select customers.id as cust_id, titles.name as title, titles.id as id from titles,
			 customers, subscriptions where subscriptions.title = 
			titles.id and subscriptions.customer = customers.id and customers.id = ? and
			titles.archived = 0 order by title";
    my $sth = $dbh->prepare($statement) or die "cant prep ";
    $sth->execute($id) or die "can't execute";
    my @titles;
    my @wishes;
    my $week_count = 0;
    while ( my $title = $sth->fetchrow_hashref ) {

        foreach my $book (@books) {
            if ( $title->{id} eq $book ) {
                $week_count++;
                $title->{title} =
                  "<b><font size=+2>" . $title->{title} . "</font></b>";
            }
        }
        push( @titles, $title );
    }
    while ( my $wish = $sth4->fetchrow_hashref ) {
        $wish->{"id"} = $id;
        push( @wishes, $wish );

    }
    my $checkin_statement = "select checkin from customers where id = ? ";
    my $sth7 = $dbh->prepare($checkin_statement) or die "cant prep ";
    $sth7->execute($id) or die "can't execute checkin";
    my $hash_ref     = $sth7->fetchrow_hashref;
    my $last_checkin = $hash_ref->{"checkin"};
    $last_checkin =~ s/(\d\d)(\d\d)(\d\d)/$2\/$3\/20$1/;
    my ( $last_month, $last_day, $last_year ) = split( $last_checkin, /\// );
    my $length = @titles;
    $template->param(
        id                       => $id,
        last_checkin             => $last_checkin,
        phone                    => $phone,
        zip                      => $zip,
        address                      => $address,
        email                    => $email,
        login                    => $customer,
        number_of_subs_this_week => $week_count,
        number_of_subs           => $length,
        TITLES                   => \@titles,
        WISHES                   => \@wishes
    );
    $template->param( $self->session->param_hashref() );
    print $template->output();
    exit;

}

sub delete_note_today {
    my $self    = shift;
    my $dbh     = $self->{dbh};
    my $q       = $self->query();
    my $note_id = $q->param("note_id");
    my $isbn   = $q->param("isbn");
    my $sth6    = $dbh->prepare("delete from notes where id = ?");
    my $sth4 = $dbh->prepare("update books set in_stock = (in_stock + 1) where isbn = ?") 
			|| die "can't prep sth4" . $sth4->errstr;
    if ($isbn){$sth4->execute($isbn) || die "can't execute return" .$sth4->errstr};
    $sth6->execute($note_id);
    $self->today();
    exit;
}

sub member_info {
    my $self = shift;
    my $dbh  = $self->{dbh};
    my $q    = $self->query();
    my $id   = $q->param("id");
    my $note = $q->param("note");
    my $isbn = $q->param("isbn");
    my $limit = $q->param("limit") || 100;
    if ( $q->param("rm") eq "note" ) {
        my $sth5 = $dbh->prepare("insert into notes values(NULL, $id, ?, NULL)");
        $sth5->execute($note) || die "can't insert note" . $sth5->errstr;
    }
    elsif ( $q->param("rm") eq "delete_note" ) {
        my $note_id = $q->param("note_id");
        my $sth6    = $dbh->prepare("delete from notes where id = ?");
    	my $sth4 = $dbh->prepare("update books set in_stock = (in_stock + 1) where isbn = ?") 
			|| die "can't prep sth4" . $sth4->errstr;
    	if ($isbn){$sth4->execute($isbn) || die "can't execute return" .$sth4->errstr};
        $sth6->execute($note_id);
    }
    elsif ( $q->param("rm") eq "add_credit" ) {
        my $amount = $q->param("amount");
        my $sth    =
          $dbh->prepare(
            "update book_club set credit = credit + ? where id = ?");
        $sth->execute( $amount, $id ) || die "can't add credit: $!";
        my $sth2 = $dbh->prepare("insert into notes values(NULL, $id, NULL )");
        my $note = `date '+%a %m/%d/%y'` . " manually added \$$amount";
        $sth2->execute($note);
    }
    elsif ( $q->param("rm") eq "use_credit" ) {
        my $amount = $q->param("amount");
        my $sth    =
          $dbh->prepare(
            "update book_club set credit = credit - ? where id = ?");
        $sth->execute( $amount, $id ) || die "can't use credit: $!";
        my $sth2 =
          $dbh->prepare("insert into notes values(NULL, $id, ?, NULL)");
        my $note = `date '+%a %m/%d/%y'` . " spent \$$amount";
        $sth2->execute($note);
    }
    elsif ( $q->param("rm") eq "buy_book" ) {
        my $rebate = $q->param("rebate");
        my $book   = $q->param("book");
        my $price  = $q->param("price");
        my $credit = $q->param("credit");
        my $isbn   = $q->param("isbn");
        my $sth    =
          $dbh->prepare(
"update book_club set credit = credit +((?/100)*(?-?))  where id = ?"
          );
        my $sth2 = $dbh->prepare("insert into notes values(NULL, $id, ?, ?)");
        my $note =
          `date '+%a %m/%d/%y'` . "$book \@ \$$price - \$$credit x $rebate\%";
        my $sth3 =
          $dbh->prepare(
            "update book_club set credit = credit - ? where id = ?");
        my $sth4 = $dbh->prepare("update books set in_stock = in_stock -1 where isbn = ?") 
			|| die "can't prep sth4" . $sth4->errstr;
        $sth4->execute($isbn) || die "can't execute sth4" . $sth4->errstr;
        $sth3->execute( $credit, $id ) || die "can't use credit: $!";
        $sth->execute( $rebate, $price, $credit, $id )
          || die "can't buy book: $!";
        $sth2->execute( $note, $isbn );

    }
    my $template = $self->load_tmpl( 'member_info.tmpl.html', cache => 1 );

    my $sth2 =
      $dbh->prepare(
        "select name, email, phone, zip, credit, address from book_club where id=\"$id\""
      );
    $sth2->execute();
    my $sth3 = $dbh->prepare("select distinct id from this_week");
    $sth3->execute();
    my @books;
    my $sth4 =
      $dbh->prepare(
"select note, id  as note_id, isbn from notes where customer_id=\"$id\"  order by note_id desc limit $limit"
      );
    $sth4->execute() || croak $sth4->errstr;

    while ( my $title = $sth3->fetchrow_hashref ) {
        push @books, $title->{id};
    }
    my ( $customer, $email, $phone, $zip, $credit, $address ) = $sth2->fetchrow_array;

    my $statement = "select titles.name as title, titles.id as id from titles,
			 customers, subscriptions where subscriptions.title = 
			titles.id and subscriptions.customer = customers.id and customers.id = ? and
			titles.archived = 0 order by title";
    my $sth = $dbh->prepare($statement) or die "cant prep ";
    $sth->execute($id) or die "can't execute";
    my @titles;
    my @notes;
    my $week_count = 0;
    while ( my $title = $sth->fetchrow_hashref ) {
        foreach my $book (@books) {
            if ( $title->{id} eq $book ) {
                $week_count++;
                $title->{title} =
                  "<b><font size=+2>" . $title->{title} . "</font></b>";
            }
        }
        push( @titles, $title );
    }
    while ( my $note = $sth4->fetchrow_hashref ) {
        $note->{"id"} = $id;
        push( @notes, $note );
    }
    my $checkin_statement = "select checkin from customers where id = ? ";
    my $sth7 = $dbh->prepare($checkin_statement) or die "cant prep ";
    $sth7->execute($id) or die "can't execute checkin";
    my $hash_ref     = $sth7->fetchrow_hashref;
    my $last_checkin = $hash_ref->{"checkin"};
    $last_checkin =~ s/(\d\d)(\d\d)(\d\d)/$2\/$3\/20$1/;
    my ( $last_month, $last_day, $last_year ) = split( $last_checkin, /\// );
    my $length = @titles;
    $template->param(
        id     => $id,
        phone  => $phone,
        zip    => $zip,
        email  => $email,
        address  => $address,
        login  => $customer,
        credit => $credit,
        NOTES  => \@notes
    );
    $template->param( $self->session->param_hashref() );
    print $template->output();
    exit;

}

sub clone_title {
    my $self     = shift;
    my $dbh      = $self->{dbh};
    my $q        = $self->query();
    my $title_id = $q->param("title_id");
    my $clone_id = $q->param("clone_id");
    my $sth      =
      $dbh->prepare("select customer from subscriptions where title = ?")
      or die "cant prep ";
    my $sth2 =
      $dbh->prepare("insert into subscriptions(title, customer) values(?,?)")
      or die "cant prep ";
    $sth->execute($clone_id);

    while ( my $subscriber = $sth->fetchrow_hashref ) {
        my $customer_id = $subscriber->{'customer'};
        $sth2->execute( $title_id, $customer_id );
    }
    $self->title_info();
}

sub title_info {
    my $self      = shift;
    my $dbh       = $self->{dbh};
    my $q         = $self->query();
    my $title_id  = $q->param("title_id");
    my $statement = "select name, archived from titles where id = \"$title_id\"";
    my $sth       = $dbh->prepare($statement) or die "cant prep ";
    $sth->execute();
    my ($title, $archived) = $sth->fetchrow_array;

    my $statement2 = "select customers.name as name, customers.id as id from customers,titles,
                        subscriptions where subscriptions.title = titles.id
                         and subscriptions.customer = customers.id and 
                         subscriptions.title = \"$title_id\" and customers.frozen = 0 order by name";
    my $sth2 = $dbh->prepare($statement2) or die "cant prep ";
    $sth2->execute() || die "can't get subscribers";
    my @subscribers;
    while ( my $subscriber = $sth2->fetchrow_hashref ) {
	#$subscriber->{foo_id} = $subscriber->{id};
        push( @subscribers, $subscriber );
    }
    my $length = @subscribers;

    my $template = $self->load_tmpl(
        'title_info.tmpl.html',
        cache             => 1,
        die_on_bad_params => 0
    );
    $template->param( TITLE => $title, id => $title_id, archived => $archived, length => $length );

    $template->param( CUSTOMERS => \@subscribers );
    $template->param( $self->session->param_hashref() );
    print $template->output();
    exit;

}

sub unsubscribe {
    my $self = shift;
    my $dbh  = $self->{dbh};
    my $q    = $self->query();
    my $sth  =
      $dbh->prepare(
        "delete from subscriptions where customer = ? and title =  ?")
      || die "can't prep";
    my $title_id = $q->param("title_id");
    my $id       = $q->param("id");
    $sth->execute( $id, $title_id ) or die "can't delete";
    if ( $q->param("bm") eq "info" ) {
        $self->customer_info();
    }
    else {
        $self->title_form();
    }
    exit;
}

sub subscriptions {
    my $self     = shift;
    my $dbh      = $self->{dbh};
    my $q        = $self->query();
    my $template = $self->load_tmpl( 'subscriptions.tmpl.html', cache => 1 );
    my $sth      =
      $dbh->prepare("select name from titles where archived=0 order by name")
      or die "cant prep ";
    $sth->execute();
    my @titles;
    while ( my ($title) = $sth->fetchrow_array ) {
        push( @titles, $title );
    }
    my $sth2 = $dbh->prepare(
"select customers.name as customer from customers, titles, subscriptions 
				where subscriptions.title = titles.id and subscriptions.customer = customers.id
				and titles.name = ? and customers.frozen=0 and titles.archived=0 order by customer"
      )
      or die "cant prep ";
    $template->param( $self->session->param_hashref() );
    print $template->output();
    print "<ol>\n";
    foreach my $title (@titles) {
        my @customers;
        print "<li><b>$title</b>";
        $sth2->execute($title) or die "cant execute";
        while ( my ($customer) = $sth2->fetchrow_array ) {
            push @customers, "<li>$customer";
        }
        my $length = @customers;
        print "(<b>", $length, "</b>)\n";
        print "<ol>\n";
        foreach (@customers) { print $_}
        print "</ol>\n";
    }
    print "</ol>\n";
    exit;

}


sub week_subs_by_cust {
    #croak "mode not implemented yet";
    my $self     = shift;
    my $dbh      = $self->{dbh};
    my $q        = $self->query();
    my $template = $self->load_tmpl( 'subscriptions.tmpl.html', cache => 1 );
    my $sth      = $dbh->prepare( "select * from customers where frozen = 0 order by name" ) or die "cant prep ";
    my $sth2      = $dbh->prepare( "select distinct(this_week.id), titles.name from  subscriptions, this_week, titles where titles.id = subscriptions.title and subscriptions.title  = this_week.id and titles.archived = 0  and subscriptions.customer = ? order by name" ) or die "cant prep ";
    $sth->execute() || die "can't execute sth1" . $sth->errstr;
    my @customers;
    while ( my $cust = $sth->fetchrow_hashref ) {
		$sth2->execute($cust->{'id'}) || die "can't execute sth2" . $sth2->errstr;
		my @subs;
		while ( my $title = $sth2->fetchrow_hashref){
			push @subs, $title;
		}
		$cust->{'subs'}  = \@subs;
        push( @customers, $cust);
    }
    my $template = $self->load_tmpl(
        'subs_by_cust.tmpl.html',
        die_on_bad_params => 0
    );
    $template->param( CUSTOMERS => \@customers );
    $template->param( $self->session->param_hashref() );
    print $template->output();
	exit;

}

sub week_subs {
    my $self     = shift;
    my $dbh      = $self->{dbh};
    my $q        = $self->query();
    my $template = $self->load_tmpl( 'subscriptions.tmpl.html', cache => 1 );
    my $sth      = $dbh->prepare(
        "select distinct titles.name from titles, 
				this_week where titles.id = this_week.id 
				order by titles.name"
      )
      or die "cant prep ";
    $sth->execute();
    my @titles;

    while ( my ($title) = $sth->fetchrow_array ) {
        push( @titles, $title );
    }
    my $sth2 = $dbh->prepare(
"select customers.name as customer from customers, titles, subscriptions 
					where subscriptions.title = titles.id and subscriptions.customer = customers.id
					and titles.name = ? and customers.frozen = 0 order by customer"
      )
      or die "cant prep ";
    print $template->output();
    print "<ol>\n";
    foreach my $title (@titles) {
        my @customers;
        print "<li><b>$title</b>";
        $sth2->execute($title) or die "cant execute";
        while ( my ($customer) = $sth2->fetchrow_array ) {
            push @customers, "<li>$customer";
        }
        my $length = @customers;
        print "(<b>", $length, "</b>)\n";
        print "<ol>\n";
        foreach (@customers) { print $_}
        print "</ol>\n";
    }
    print "</ol>\n";
    exit;

}

sub show_preview {
    my $self     = shift;
    my $template = $self->load_tmpl( 'preview.tmpl', cache => 1 );
    my $q        = $self->query();
    my $text     = $q->param("log_entry");
    my $title    = $q->param("log_title");
    $template->param( TEXT  => $text );
    $template->param( TITLE => $title );
    print $q->header( -type => 'text/html' ), $template->output();
    exit;
}

sub checkin {
    my $self = shift;
    my $q    = $self->query();
    my $id   = $q->param("id");
    my $dbh  = $self->{dbh};
    my $gmt  = gmtime();
    my ( $year, $month, $day ) = Today($gmt);
    $year =~ s/\d\d(\d\d)/$1/;
    if ( $month < 10 ) { $month = 0 . $month }
    if ( $day < 10 )   { $day   = 0 . $day }
    $today = $year . $month . $day;
    my $sth = $dbh->prepare("update customers set checkin = ?  where id = ?")
      or die "cant prep";
    $sth->execute( $today, $id ) || die "can't checkin :" . $sth->errstr;
    customer_info($self);
}

sub checkin_member {
    my $self = shift;
    my $q    = $self->query();
    my $id   = $q->param("id");
    my $dbh  = $self->{dbh};
    my $sth  = $dbh->prepare("update book_club set checkin = NULL where id = ?")
      or die "cant prep";
    $sth->execute($id) || die "can't checkin :" . $sth->errstr;
    customer_info($self);
}

sub import_invoice {
    my $self     = shift;
    my $q        = $self->query();
    my $template = $self->load_tmpl( 'confirm_invoice.tmpl.html', cache => 1 );
    my $dbh      = $self->{dbh};
    my $file     = $q->upload("invoice");
    my $sth2     =
      $dbh->prepare(
"select invoice_id + 1 as new_invoice_id from invoices order by invoice_id desc limit 1"
      );
    my $sth3 =
      $dbh->prepare(
        "select hijinx_id, batchno, linenum from orders where itemno = ?" );
    $sth2->execute() || die "can't get new id: " . $sth->errstr;
    my $row        = $sth2->fetchrow_hashref();
    my $invoice_id = $row->{new_invoice_id};
    if ( $invoice_id < 1 ) { $invoice_id = 1 }
    my $sth =
      $dbh->prepare(
"insert into invoices values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
      )
      || die "can't prep sth: $sth->errstr;";

    foreach (<$file>) {

        #s/\"//g;
        s/\r//;    #strip off carriage returns
        if ( $_ =~ /^\"/ ) {    #if line starts with a quote
            s/\"//g;
            push @headers, $_;
        }
        elsif ( $_ =~ /^\d/ || $_ =~ /^\-/ ) {
            s/\"//g;
	    ## add fix here for new invoice field
            my (
                $qty,          $itemno, $discount,  $descr,  $retail_price,
                $unit_price,   $inv_amt,  $cat_id, $order_type,
                $processed_as, $order_no, $upc,    $isbn,
                $ean,          $po_no,    $allocated
              )
              = split(/,/);
            my $date = $headers[3];
            chomp $date;
            $date =~ s/(\d\d)\/(\d\d)\/(\d\d)/20$3-$1-$2/;
            my $account_num = $headers[1];
            #$discount =~ s/ //g;
            #chop $itemno;
            #my $discount = chop $itemno;
            $sth3->execute($itemno) || warn "can't execute";
            my $order_line = $sth3->fetchrow_hashref();
            my $hijinx_id  = $order_line->{hijinx_id};
            my $batchno    = $order_line->{batchno};
            my $linenum    = $order_line->{linenum};
            $sth->execute( NULL, $invoice_id, $qty, $itemno,
                $descr,     $retail_price, $unit_price,   $inv_amt,
                $cat_id,    $order_type,   $processed_as, $order_no,
                $upc,       $isbn,         $ean,          $po_no,
                $allocated, $date,         $discount,     $account_num,
                $batchno,   $hijinx_id,    $linenum,      NULL,
                NULL
              )
              || warn "can't insert: " . $sth->errstr;
        }
    }
    $self->orders();
}

sub receive_invoice {
    #use Business::ISBN qw(ean_to_isbn is_valid_checksum);
	use Net::Amazon;
    my $self     = shift;
    my $q        = $self->query();
    my $template = $self->load_tmpl( 'confirm_invoice.tmpl.html', cache => 1 );
    my $dbh      = $self->{dbh};
    my $invoice_id = $q->param("invoice_id");
    my $data;
    my $total = 0;
    my @issues;

    my $sth = $dbh->prepare("select id from titles where name = ?")
      || die "can't prep sth:$!";
    my $sth2 = $dbh->prepare(
        "insert into cycles values(?,?,?,DATE_FORMAT(?, '%m/%d/%y'),
                                DATE_FORMAT(?, '%m/%d/%y'),?,?,?,?,?,?,?,?,?,?)"
      )
      or die "can't prep sth2:$!";
    my $sth3 = $dbh->prepare("insert into this_week(id) values(?)");
    my $sth4 = $dbh->prepare( "update cycles set reorder = reorder + ?, week_2 = week_2 + ?, upc = ?  where title_id = ? and issue = ?");
    my $sth7 = $dbh->prepare( "update cycles set rcv_qty = rcv_qty + ?,week_1 = week_1 + ?, week_2 = week_2 + ?, upc = ? where title_id = ? and issue = ?");
    my $sth5 =
      $dbh->prepare(
"select count(customer) as subs from subscriptions, customers where customers.frozen = 0 and  title= ? and subscriptions.customer = customers.id"
      )
      or die "can't prep";
    my $sth6 = $dbh->prepare("select * from invoices where invoice_id = ?")
      or die "can't prep 6";

    if ( $q->param("rotate") eq "upload and rotate weeks" ) {
        $dbh->do("delete from next_week_4 where id > 0");
        $dbh->do(
"insert into next_week_4 select distinct * from next_week_3 where next_week_3.id > 0"
        );
        $dbh->do("delete from next_week_3 where id > 0");
        $dbh->do(
"insert into next_week_3 select distinct * from next_week_2 where next_week_2.id > 0"
        );
        $dbh->do("delete from next_week_2 where id > 0");
        $dbh->do(
"insert into next_week_2 select distinct * from next_week where next_week.id > 0"
        );
        $dbh->do("delete from next_week where id > 0");
        $dbh->do(
"insert into next_week select distinct * from this_week where this_week.id > 0"
        );
        $dbh->do("delete from this_week where id > 0");
    }
    my @reorders;
    my $number = 1;
    my $status = 1;
    $sth6->execute($invoice_id) || warn "can't get invoice";
    while ( my $inv_line = $sth6->fetchrow_hashref() ) {
        my $qty      = $inv_line->{qty};
        my $dcd      = $inv_line->{itemno};
        my $desc     = $inv_line->{descr};
        my $title     = $desc;
        my $price    = $inv_line->{retail_price};
        my $cost     = $inv_line->{unit_price};
        my $ext_cost = $inv_line->{inv_amy};
        my $cat      = $inv_line->{cat_id};
        my $type     = $inv_line->{order_type};
        my $blank    = $inv_line->{processed_as};
        my $ean      = $inv_line->{ean}, 
        my $isbn = $inv_line->{isbn};
        my $upc = $inv_line->{upc};
        my $discount = $inv_line{discount};
        my ( $title, $issue );

        if ( $desc =~ /\#/ ) {
            ( $title, $issue ) = split( /\#/, $desc );
            $title =~ s/\s*^//;           #trim whitespace
            $issue =~ s/^(\d*)?.*$/$1/;
        }
        else {
            $title = $desc;
            $issue = 0;
        }
        if ( $cat <= 2) {
	    #it's a comic
            my $status = $sth->execute($title);
            if ( $status == 1 ) {
		#title exists
                my $id = $sth->fetchrow_array;
                my $subs;
                $sth5->execute($id);
                $row = $sth5->fetchrow_hashref()
                  or warn "can't fetch: " . $sth->errstr;
                $subs = $row->{subs};
		if ($self->issue_exists($id,$issue) ne "no issue" ){
			#issue exists in cycles
			if ($type == 2 || $type == 5 || $type == 7){
				$sth4->execute($qty, $qty, $upc, $id, $issue) || warn "can't update reorder cycle for $title";
			}elsif ($type == 1 || $type == 3 || $type == 4){
				$sth7->execute($qty, $qty, $qty, $upc, $id, $issue) || warn "can't update cycle for $title" . $sth->errstr;
			}
		}else{
			#issue doesn't exist in cycles
                	$sth2->execute(
                    	$id, $issue, $qty, NULL, NULL, $qty,
                    	$qty - $subs,
                    	$qty - $subs,
                    	NULL, NULL, NULL, "", $dcd, $subs, $upc
                  	) || warn "can't insert new issue $title $issue" . $sth2->errstr;


		}
		if ($type == 1 || $type == 3 || $type ==4){
			$sth3->execute($id) || warn "can't insert into this week $title"; #insert into this week
		}
            }
            else {
                push @issues,
                  {
                    title  => $title,
                    issue  => $issue,
                    qty    => $qty,
                    number => $number,
                    dcd    => $dcd,
                    upc    => $upc
                  };
                $number++;
            }
        }
        else { #not a comic book
        	if (length( $isbn) > 1) {
				my $sth = $dbh->prepare( "select * from books where isbn = ? ") 
				|| warn "can't prep: " . $sth->errstr;
				my $sth2 = $dbh->prepare( "insert into books values(NULL,?,?,?,?,?,?,?,?,?)") 
					|| warn "can't prep:$!" . $sth2->errstr ;
				my $sth3 = $dbh->prepare(
					 "update books set dcd  = ?,  price = ?,  upc = ?,    in_stock = in_stock + ?, on_order = on_order - ? where isbn = ?  ")
				|| warn "can't prep:$!" . $sth3->errstr ;
				my $sth4 = $dbh->prepare( "update books set in_stock = 0 where in_stock < 0");
				my $sth5 = $dbh->prepare( "update books set on_order = 0 where on_order < 0");
			$sth->execute($isbn) || warn "can't execute" . $sth->errstr;
			#insert isbn and such into books
        	if ($sth->rows == 0){  #isbn not in db
					if ( is_valid_checksum($isbn) eq Business::ISBN::GOOD_ISBN ) {
						my $ua       = Net::Amazon->new( token => '1HNDXRF1YQR9X54K9R02', secret_key => 'eWIPQ1bscu/AhDQQ3QLCMCRnXah30QhmovqgZKbk' )|| die;
						my $response = $ua->search( asin       => $isbn );
						my ( $info);
						if ($response->is_success()){
							for ( $response->properties ) {
								#$a_title = $_->ProductName();
								#$price = $_->ListPrice();
								#$info = $_->authors();
								#$info = 1;
								$price =~ s/\$//;
							}
							$sth2->execute($dcd,$title,$price,$isbn,$upc,$info,$qty,$qty,0) 
								|| warn "can't add new book" . $sth2->errstr;
						}else{
							$sth2->execute($dcd,$title,$price,$isbn,$upc,$info,$qty,$qty,0) 
								|| warn "can't add new book" . $sth2->errstr;
							warn "can't find $title $isbn";
							next;
						}
					}else{
							#bad chksum
			
					}
					
				}else{
					#isbn is in db
							my $on_order;
							if ($qty <  0){
								$on_order = 0;
							}else{
								$on_order = $qty;
							}
						$sth3->execute($dcd,$price,$upc,$qty,$on_order,$isbn) 
						|| warn "can't update book" . $sth3->errstr;
							
				}
				$sth4->execute() || warn "can't execute sth4" . $sth4->errstr;
				$sth5->execute() || warn "can't execute sth5" . $sth5->errstr;
		}else{
			next;
		}
        }
    }
    $data .= $total;
    $template->param( ISSUES => \@issues );
    print $template->output();
    exit;
}

sub confirm_invoice {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $sth  = $dbh->prepare("select id from titles where name = ?")
      || die "can't prep sth:$!";
    my $sth3 = $dbh->prepare("insert into titles values(?,?,0)")
      or die "cant prep sth 4";
    my $sth2 = $dbh->prepare(
        "insert into cycles values(?,?,?,DATE_FORMAT(?, '%m/%d/%y'),
                                DATE_FORMAT(?, '%m/%d/%y'),?,?,?,?,?,?,?,?,?,?)"
      )
      or die "can't prep sth2:$!";
    my $sth4 = $dbh->prepare("insert into this_week(id) values(?)");
    my $subs;
    my $sth5 =
      $dbh->prepare(
"select count(customer) as subs from subscriptions, customers where customers.frozen = 0 and  title= ? and subscriptions.customer = customers.id"
      )
      or warn "can't prep";
    my $sth6 =
      $dbh->prepare(
"update cycles set reorder = reorder + ?, week_2 = week_2 + ?, upc = ? where title_id = ? and issue = ?"
      );
    $sth5->execute($title_id);
    $row = $sth5->fetchrow_hashref() or warn "can't fetch: " . $sth->errstr;
    $subs = $row->{subs};
    my $inc = 1;

    while ( $q->param("title_$inc") ) {
        my $action = $q->param("action_$inc");
        my $title = $q->param("title_$inc");
        my $issue = $q->param("issue_$inc");
        my $qty   = $q->param("qty_$inc");
        my $dcd   = $q->param("dcd_$inc");
        my $upc   = $q->param("upc_$inc");
        if ( $action == 1 ) {
            $sth3->execute( undef, $title )
              || die "problem adding $title" . $sth3->errstr;
            $sth->execute($title);
            my $book = $sth->fetchrow_hashref;
            my $id   = $book->{"id"};
            $sth4->execute($id);

            if ( $self->issue_exists( $id, $issue ) ne "no issue" ) {
                #issue exists in cycles
                $sth6->execute( $qty, $qty, $upc, $id, $issue )
                  || warn "can't update cycle for $title";
            }
            else {
                $sth2->execute(
                    $id,  $issue, $qty, NULL, NULL, $qty, $qty, $qty,
                    NULL, NULL,   NULL, "",   $dcd, $subs, $upc )
                  || die "can't do it!  $id, $issue, $qty,$dcd, $subs, $upc "  . $sth2-errstr;
            }
        }
        elsif ( $action == 3 ) {
            my $alt_id = $q->param("alt_id_$inc");
            $sth4->execute($alt_id);
            if ( $self->issue_exists( $alt_id, $issue ) ne "no issue" ) {
                #issue exists in cycles
                $sth6->execute( $qty, $qty, $upc, $alt_id, $issue )
                  || warn "can't update cycle for $title";
            }
            else {
                $sth2->execute(
                    $alt_id, $issue, $qty, NULL, NULL, $qty,
                    $qty,    $qty,   NULL, NULL, NULL, "",
                    $dcd,    $subs, $upc
                  )
                  || die "can't do it!  $id, $issue, $qty,$dcd ";
            }
        }
        $inc++;
    }

    $self->this_week();
    exit;
}

sub today {
    use HTML::CalendarMonthSimple;
    my $self     = shift;
    my $q        = $self->query();
    my $template = $self->load_tmpl( 'today.tmpl.html', cache => 1, die_on_bad_params => 0 );
    my $dbh      = $self->{dbh};
    my $cal;
    my $today;
    my $online_order_date;
    if ( $q->param("date") ) {
        $today = $q->param("date");
    	my ( $year,     $month,     $day )     = date_split($today);
        $online_order_date = "20$year-$month-$day";
    }
    else {
        $gmt = gmtime();
        my ( $year, $month, $day ) = Today($gmt);
        $online_order_date = "$year-$month-$day";
        $year =~ s/\d\d(\d\d)/$1/;
        if ( $month < 10 ) { $month = 0 . $month }
        if ( $day < 10 )   { $day   = 0 . $day }
        $today = $year . $month . $day;
    }
    my $sth;
    $sth =
      $dbh->prepare(
        "select id , name from customers where checkin = ? order by name");
    $sth2 = $dbh->prepare(
        "select book_club.name as name, book_club.id as cust_id, note,
				 notes.id as note_id, isbn from notes, book_club where note 
				like ? and book_club.id = notes.customer_id;"
    );
    $sth3 = $dbh->prepare(
        "select d_notes.d_note as d_note, d_notes.id as d_id, passwd.login as 
					emp_name from d_notes, passwd where d_notes.date = ? and
					d_notes.employee_id = passwd.id order by d_id asc"
      )
      || die "can't:" . $sth->errstr;
    my ( $year,     $month,     $day )     = date_split($today);
    my ( $nextyear, $nextmonth, $nextday ) =
      Add_Delta_YM( $year, $month, $day, 0, +1 );
    my ( $lastyear, $lastmonth, $lastday ) =
      Add_Delta_YM( $year, $month, $day, 0, -1 );
    foreach ( $nextyear, $nextmonth, $nextday, $lastyear, $lastmonth, $lastday )
    {
        if ( $_ < 10 ) { $_ = "0" . $_ }
    }
    my $nextdate = "$nextyear$nextmonth$nextday";
    my $lastdate = "$lastyear$lastmonth$nextday";
    $sth->execute($today);
    $sth3->execute($today) || die "can't do it:";
    my $club_date = "\%$month/$day/$year\%";
    $sth2->execute($club_date);
    my $c = new HTML::CalendarMonthSimple(
        'today_year'  => "20" . $year,
        'today_month' => $month,
        'today_date'  => $day
    );
    $c->width('200');
    $c->border('1');
    $c->todaycolor('orange');
    $c->weekdays( "mon", "tue", "wed", "thu", "fri" );
    $c->saturday("sat");
    $c->sunday("sun");

    foreach my $day ( 1 .. 31 ) {
        if ( $day < 10 ) {
            $day = "0" . $day;
        }
        $c->setdatehref( $day, "?rm=today&date=$year$month$day" );
    }
    $cal = $c->as_HTML();
    my @customers;
    my @book_club;
    while ( my $customer = $sth->fetchrow_hashref ) {
        push( @customers, $customer );
    }
    while ( my $member = $sth2->fetchrow_hashref ) {
        $member->{'today'} = $today;
        push( @book_club, $member );
    }
    my @d_notes;
    while ( my $d_note = $sth3->fetchrow_hashref ) {
        $d_note->{'today'} = $today;
        push( @d_notes, $d_note );
    }
    my $total_customers = @customers;
    my $online_orders = $self->online_orders($online_order_date);
    $template->param(
        TODAY           => $today,
        NEXTDATE        => $nextdate,
        LASTDATE        => $lastdate,
        CAL             => $cal,
        CUSTOMERS       => \@customers,
        D_NOTES         => \@d_notes,
        BOOK_CLUB       => \@book_club,
        TOTAL_CUSTOMERS => $total_customers,
	ONLINE_ORDER_DATE => $online_order_date,
	ONLINE_ORDERS => $online_orders,
    );
    $template->param( $self->session->param_hashref() );
    print $template->output();
    exit;

}

sub online_orders {
    my $self = shift;
    my $date  = shift;
    my $dbh  = $self->{dbh};
    my $sth = $dbh->prepare("select name, order_id, type from online_orders where date = ?");
    $sth->execute($date);
    my @array;
    while (my $order=$sth->fetchrow_hashref){
		push @array, $order ;
	}
    return \@array;


}

sub parse_date {
    my $date1 = shift;
    my $date2 = shift;
    my ( $year1, $month1, $day1 ) = date_split($date1);
    my ( $year2, $month2, $day2 ) = date_split($date2);
    my $Dd = Delta_Days( $year1, $month1, $day1, $year2, $month2, $day2 );
    return $Dd;
}

sub date_split($) {
    my $date  = shift;
    my $year  = substr( $date, 0, 2 );
    my $month = substr( $date, 2, 2 );
    my $day   = substr( $date, 4, 2 );
    if ($year) {
        return ( $year, $month, $day );
    }
    else {
        return ( 03, 01, 01 );
    }
}

sub detail {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $mode;
    if ( $q->param('mode') ) {
        $template_path = "$template_path/" . $q->param('mode');
        $mode          = $template_path;
    }

    my $template =
      $self->load_tmpl( "$template_path/detail.tmpl.html", cache => 1 );
    my $id  = $q->param('id');
    my $sth = $dbh->prepare(
        "select ID, DISCOUNT, DCD, TITLE, PRICE, ISBN, URL_MED,
				 URL_BIG, INFO, UPC_1, UPC_2 from books where id = ? ;"
      )
      || die "can't prep:$!";
    $sth->execute($id) || die "can't select details:$!";
    my $name;
    while ( my $title = $sth->fetchrow_hashref ) {

        if ( $q->param('size') eq "big" ) {
            $title->{'URL_MED'} = $title->{'URL_BIG'};
        }
        push( @titles, $title );
        $name = $title->{'TITLE'};
    }
    $template->param( TITLES => \@titles );
    print $template->output();
    exit;
}
sub edit_book_results {
	my $self = shift;    
	my $q    = $self->query();
	my $search_term = $q->param('search_term');
	my @ids = $q->param('id');
	my $dbh  = $self->{dbh};
	my $sth = $dbh->prepare( "update books set min = ?, in_stock =?, on_order =? where id = ?") 
			|| die "can't prep:$!";
	foreach my $id (@ids){
		my $min = $q->param("min_$id");
		my $in_stock = $q->param("in_stock_$id");
		my $on_order = $q->param("on_order_$id");
		$sth->execute($min, $in_stock, $on_order, $id);
	}
	$q->param( -name => 'search_term', -value => $search_term );
 	if ( $q->param('bm') eq "reorder"){
		$self->book_reorders();
         }elsif($q->param('bm') eq "os"){
	    $self->outstanding_book_reorders();
	 }else{
	    $self->book_search();
	}
}
sub book_search {
	my $self = shift;    
	my $q    = $self->query();
	my $search_term = $q->param('search_term');
	my $dbh  = $self->{dbh};
	my $sth;
	my @results;
	$sth = $dbh->prepare( "select * from books where title like ? order by title") || die "can't prep:$!";
	$sth->execute("\%$search_term\%")|| die "can't execute" . $sth->errstr;
	my $sth2 = $dbh->prepare("select count(isbn) as num from notes where isbn = ?") || die "can't prep:$!";
	my $sth3 = $dbh->prepare("select (rcvd - sold) as used_in_stock from used_book where isbn = ?") || die "can't prep:$!";
	while ( my $book = $sth->fetchrow_hashref ) {
		my $isbn = $book->{'isbn'};
		$sth2->execute($isbn) || warn "can't get sales history" . $sth2->errstr;
		$sth3->execute($isbn) || warn "can't get sales history" . $sth2->errstr;
		my $hist = $sth2->fetchrow_hashref;
		$book->{'used_in_stock'} = $sth3->fetchrow_hashref;
		$book->{'sold'} = $hist->{'num'};
		$book->{'search_term'} = $search_term;
		push @results, $book;
	}
    my $template = $self->load_tmpl( "$template_path/books.tmpl.html", cache => 1, die_on_bad_params => 0 )
      || die "can't load $template_path/baooks.tmpl.html \n";
    $template->param( BOOKS => \@results,
			SEARCH_TERM => $search_term,
		     );
    print $template->output();
    exit;
}

sub book_reorders {
	my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $sth = $dbh->prepare( "select *  from books where (min - in_stock - on_order) > 0 order by title ;") || die "can't prep:$!";
    my $sth2 = $dbh->prepare("select count(isbn) as num from notes where isbn = ?") || die "can't prep:$!";
    my $sth3 = $dbh->prepare( "select sum((min - in_stock - on_order)*price) as retail_total  from books where (min - in_stock - on_order) > 0 ;") || die "can't prep:$!";
    my $sth4 = $dbh->prepare( "update books set on_order =( on_order + (min - in_stock - on_order)) where (min - in_stock - on_order) > 0 ;") || die "can't prep:$!";
    my $sth5 = $dbh->prepare( "select * from tags where id = ? and type = 'book' and tag like ? ;") || die "can't prep:$!";
    $sth->execute() || die "can't select books" . $sth->errstr;
    $sth3->execute() || die "can't select books" . $sth->errstr;
    my $res = $sth3->fetchrow_hashref;
    my @results;
	while ( my $book = $sth->fetchrow_hashref ) {
		my $isbn = $book->{'isbn'};
		my $id = $book->{'id'};
		$sth5->execute($id,'vendor:%') || die "can't get sales vendor" . $sth2->errstr;
		my $vendor = $sth5->fetchrow_hashref;
		$book->{'vendor'} = $vendor->{'tag'};
		$sth2->execute($isbn) || warn "can't get sales history" . $sth2->errstr;
		my $hist = $sth2->fetchrow_hashref;
		$book->{'sold'} = $hist->{'num'};
		$book->{'qty'} = ($book->{'min'} - $book->{'in_stock'} - $book->{'on_order'});
		$book->{'search_term'} = $search_term;
		push @results, $book;
	}
    my $template;
    unless ($q->param('mode') eq "export"){
    	$template = $self->load_tmpl( "$template_path/book_reorders.tmpl.html", cache => 1, die_on_bad_params => 0 )
      		|| die "can't load $template_path/baooks.tmpl.html \n";
	my $vendors = $self->unique_vendors();
        $template->param( BOOKS => \@results,
			SEARCH_TERM => $search_term,
			VENDORS => $vendors,
			RETAIL_TOTAL => $res->{'retail_total'},
			);
		}else{
    	$template = $self->load_tmpl( "$template_path/export_reorder.tmpl.html", cache => 1, die_on_bad_params => 0 )
      		|| die "can't load $template_path/baooks.tmpl.html \n";
        $template->param( BOOKS => \@results,
			RETAIL_TOTAL => $res->{'retail_total'},
			);
    print $q->header( -type => 'text/plain' );
    if ($q->param('clear') == 1){$sth4->execute() || die "can't execute sth4 " . $sth4->errstr;}

	}

    print $template->output();
	exit;
}

sub unique_vendors {
	my $self = shift;
    	my $dbh  = $self->{dbh};
    	my $sth = $dbh->prepare( "select distinct tag from tags where tag like 'vendor:%' order by tag;") || die "can't prep:$!";
	$sth->execute();
	my @vendors;
	while ( my $ref  = $sth->fetchrow_hashref){
		my $name =  $ref->{'tag'};
		$name =~ s/^vendor://;
		$ref->{'vendor'} = $name;
		push  @vendors, $ref;
	}
	return \@vendors;
}

sub outstanding_book_reorders {
	my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $sth = $dbh->prepare( "select *  from books where  on_order > 0 order by title ;") || die "can't prep:$!";
    my $sth2 = $dbh->prepare("select count(isbn) as num from notes where isbn = ?") || die "can't prep:$!";
    my $sth3 = $dbh->prepare( "select sum(on_order*price) as retail_total  from books where  on_order > 0 ;") || die "can't prep:$!";
    $sth->execute() || die "can't select books" . $sth->errstr;
    $sth3->execute() || die "can't select books" . $sth->errstr;
    my $res = $sth3->fetchrow_hashref;
    my @results;
	while ( my $book = $sth->fetchrow_hashref ) {
		my $isbn = $book->{'isbn'};
		$sth2->execute($isbn) || warn "can't get sales history" . $sth2->errstr;
		my $hist = $sth2->fetchrow_hashref;
		$book->{'sold'} = $hist->{'num'};
		$book->{'qty'} = ($book->{'min'} - $book->{'in_stock'} - $book->{'on_order'});
		$book->{'search_term'} = $search_term;
		push @results, $book;
	}
    my $template;
	$template = $self->load_tmpl( "$template_path/os_book_reorders.tmpl.html", cache => 1, die_on_bad_params => 0 )
      		|| die "can't load $template_path/baooks.tmpl.html \n";
	$template->param( BOOKS => \@results,
			SEARCH_TERM => $search_term,
			RETAIL_TOTAL => $res->{'retail_total'},
			);

    print $template->output();
	exit;
}
sub books {
    #use Business::ISBN qw(ean_to_isbn is_valid_checksum);
    my $self = shift;
    my $q    = $self->query();
    my $upc = $q->param('upc');
    my $title = $q->param('title');
    my $price = $q->param('price');
    my $id = $q->param('id');
    my $info = $q->param('info' ) || "no info";
    my $isbn  = $q->param('isbn') ;
    my $min = $q->param('min') || 0;
    my $dcd = $q->param('dcd') || "" ;
    my $in_stock = $q->param('in_stock') || 0;
    my $on_order = $q->param('on_order') || 0;
	my $num;  
    $upc =~ s/\W//g;
    $upc = substr( $upc, 0, 13 );
    if ( is_valid_checksum($upc) eq Business::ISBN::GOOD_ISBN ) {
        $isbn = $upc;
        $upc  = '';
    } else {
        $isbn = $q->param('isbn') || ean_to_isbn($upc);
		#$isbn = $upc;  # ASIN ENTRY HACK
    }
    my $dbh  = $self->{dbh};
    if ($isbn){
		my $sth = $dbh->prepare( "select *  from books where isbn = ? ;") || die "can't prep:$!";
		my $sth2 = $dbh->prepare( "insert into books values(NULL,?,?,?,?,?,?,?,?,?)") || warn "can't prep:$!" ;
		my $sth3 = $dbh->prepare( "update books set  dcd  = ?, title = ?, price = ?, isbn = ?, upc = ?,  info = ?, min = ?, in_stock = ?, on_order = ? where isbn = ?  ")
					 || die "can't prep:$!" ;
		my $sth4 = $dbh->prepare("select count(isbn) as num from notes where isbn = ?")
					 || die "can't prep:$!" ;
		my $sth5 = $dbh->prepare("select book_club.name as name, notes.note as note, book_club.id as id from notes, book_club where isbn = ? and book_club.id = notes.customer_id")
					 || die "can't prep:$!" ;
		$sth5->execute($isbn) || die "can't get history" . $sth5->errstr;
		while (my $ref = $sth5->fetchrow_hashref){
			$ref->{'note'} =~ s/\n.*$//;
			push (@history, $ref);
		}
		if ($q->param('save_book') == 1){
	    	$sth3->execute( $dcd, $title, $price, $isbn, $upc, $info, $min, $in_stock, $on_order, $isbn) 
				|| die "can't update book" . $sth3->errstr;
			$sth->execute($isbn) || die "can't select titles 1:$!";
		}else{
			$sth->execute($isbn) || die "can't select titles 2:$!" . $sth->errstr;
		}
	my @history;
        if ($sth->rows == 0){
		if ( is_valid_checksum($isbn) eq Business::ISBN::GOOD_ISBN || length($isbn) == 10 ) {
        		my $ua       = Net::Amazon->new( token => '1HNDXRF1YQR9X54K9R02', secret_key => 'eWIPQ1bscu/AhDQQ3QLCMCRnXah30QhmovqgZKbk' );
        		my $response = $ua->search( asin       => $isbn );
				#$dcd = `/home/dan/cpro.hijinxcomics.com/hijinx/util_scripts/isbn2dcd.pl $isbn` || warn "cant get dcd with isbn2dcd.pl:$!";
        		if ($response->is_success()){
        			for ( $response->properties ) {
            			$title = $_->ProductName();
            			$price = $_->ListPrice();
            			#$info = $_->authors();
            			$price =~ s/\$//;
        			}
				$sth2->execute($dcd,$title,$price,$isbn,$upc,$info,$min,$in_stock,$on_order) 
					|| warn "can't add new book" . $sth2->errstr;
				}else{
					warn "BAD ISBN";
				$sth2->execute($dcd,$title,$price,$isbn,$upc,$info,$min,$in_stock,$on_order) 
					|| warn "can't add new book" . $sth2->errstr;
				}
			}
			
 		}else{
			# "found it in our db";
    		while ( my $note = $sth->fetchrow_hashref ) {
        		$id = $note->{"id"} ;
        		$isbn = $note->{"isbn"} ;
        		$title = $note->{"title"} ;
        		$dcd = $note->{"dcd"} ;
        		$price = $note->{"price"} ;
        		$upc = $note->{"upc"} ;
        		$in_stock = $note->{"in_stock"} ;
        		$min = $note->{"min"} ;
        		$on_order = $note->{"on_order"} ;
			$sth4->execute($isbn);
    			while ( my $book = $sth4->fetchrow_hashref ) {
				    $num = $book->{'num'} ;
				}
			
			}
		}
    }
	my $suggestions = $self->suggest($isbn) || die "can't suggest $!";
    my $template = $self->load_tmpl( "$template_path/books.tmpl.html", cache => 1 )
      || die "can't load $template_path/books.tmpl.html \n";
    $template->param( 
			isbn => $isbn,
			title => $title,
			price => $price,
			id => $id,
			info => $info,
			upc => $upc,
			dcd => $dcd,
			min => $min,
			on_order => $on_order,
			in_stock => $in_stock,
			num => $num ,
			history => \@history ,
			suggestions => $suggestions ,
			tags => $self->book_tags($id, $isbn) ,
 );
    $template->param( $self->session->param_hashref() );
    print $template->output();
	exit;
}
sub tag_info{
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $type =  $q->param('type');# || croak "must provide type";
    my $tag =  $q->param('tag');# || croak "must provide tag";
    my $true_tag =  uri_unescape($tag);
    my $id =  $q->param('id') ;
    my $sth = $dbh->prepare("select tags.id as id, books.title as title, books.isbn as isbn from tags, books where tag = ? and type = ? and books.id = tags.id order by title") || croak "can't prep" ;
    my @tagged_items;
    $sth->execute($true_tag, $type);
    while (my $item = $sth->fetchrow_hashref){
        $item->{'safe'} = uri_escape($tag);
        push @tagged_items, $item;
    }
    my $template = $self->load_tmpl( "$template_path/tag_info.tmpl.html", cache => 1 )
      || die "can't load $template_path/tag_info.tmpl.html \n";
    $template->param( 
			items => \@tagged_items,
			all_tags => $self->all_tags($type),
                        tag => $tag,
                        type => $type,
                    );
    print $template->output();
    exit;
}
sub book_tags{
    my $self = shift;
    my $id = shift;
    my $isbn = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    #my $id =  $q->param('id') || croak "must provide id";
    my $sth   = $dbh->prepare("select tag from tags where id = ? and type ='book' ") || croak "can't prep";
    $sth->execute($id);
    my @tags;
    while (my $tag =$sth->fetchrow_hashref){
	$tag->{'id'} = $id;
	$tag->{'isbn'} = $isbn;
	$tag->{'safe'} = uri_escape($tag->{'tag'});
        push @tags, $tag;
    }
    return \@tags;
}
sub all_tags{
    my $self = shift;
    my $type = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    #my $id =  $q->param('id') || croak "must provide id";
    my $sth   = $dbh->prepare("select distinct tag, count(tag) as count  from tags where  type = ? group by tag order by count desc, tag asc") || croak "can't prep";
    $sth->execute($type) || croak "can't execute" . $sth->errstr;
    my @tags;
    while (my $tag =$sth->fetchrow_hashref){
	$tag->{'safe'} = uri_escape($tag->{'tag'});
        push @tags, $tag;
    }
    return \@tags;
}

sub remove_tag{
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $type =  $q->param('type') || croak "must provide type";
    my $tag =  uri_unescape($q->param('tag') )|| croak "must provide tag";
    my $sth   = $dbh->prepare("delete from tags where  type = ? and tag = ?")
      or die "cant prep";
    $sth->execute($type,$tag) || croak "can't delete tag";
    if ($type eq "book"){
	$self->tag_info();
	exit;
    }
    exit;

}
sub del_tag{
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $type =  $q->param('type') || croak "must provide type";
    my $tag =  uri_unescape($q->param('tag') )|| croak "must provide tag";
    my $id =  $q->param('id') || croak "must provide id";
    my $sth   = $dbh->prepare("delete from tags where id = ? and type = ? and tag = ?")
      or die "cant prep";
    $sth->execute($id,$type,$tag) || croak "can't delete tag";
    if ($type eq "book"){
	$self->books();
	exit;
    }
    exit;

}
sub tag{
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $type =  $q->param('type') || croak "must provide type";
    my $tag =  $q->param('tag') || croak "must provide tag";
    my $id =  $q->param('id') || croak "must provide id";
    my $sth   = $dbh->prepare("insert into tags values(?,?,?)")
      or die "cant prep";
    $sth->execute($id,$type,$tag) || croak "can't insert tag";
    if ($type eq "book"){
	$self->books();
	exit;
    }
    exit;

}



sub search {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    if ( $q->param('mode') ) {
        $template_path = "$template_path/" . $q->param('mode');
    }
    my $template =
      $self->load_tmpl( "$template_path/search.tmpl.html", cache => 1 )
      || die "can't load $template_path: $!\n";

    if (   $q->param('search_term')
        || $q->param('upc_search')
        || $q->param('isbn_search') )
    {
        my $term;
        my $sth;
        if ( $q->param('desc_search') ) {
            $term = $q->param('search_term');
            $sth  = $dbh->prepare(
                "select ID, DISCOUNT, DCD, TITLE, PRICE,
					 ISBN, URL_SMALL, INFO, UPC_1 from books where match(`INFO`) against(?) ;"
              )
              || die "can't prep:$!";
        }
        elsif ( $q->param('upc_search') ) {
            $term = $q->param('search_term');
            $term =~ s/\s//g;
            $sth = $dbh->prepare(
                "select ID, DISCOUNT, DCD, TITLE, PRICE,
					 ISBN, URL_SMALL, UPC_1 from books where UPC_1  = ? ;"
              )
              || die "can't prep:$!";
            $sth2 = $dbh->prepare(
                "select ID, DISCOUNT, DCD, TITLE, PRICE,
					 ISBN, URL_SMALL, UPC_1 from books where UPC_2  = ? ;"
              )
              || die "can't prep:$!";

        }
        elsif ( $q->param('isbn_search') ) {
            $term = $q->param('search_term');
            $term =~ s/\s//g;
            $sth = $dbh->prepare(
                "select ID, DISCOUNT, DCD, TITLE, PRICE,
                                         ISBN, URL_SMALL, UPC_1 from books where ISBN  like ? ;"
              )
              || die "can't prep:$!";
        }
        else {
            $term = "\%" . $q->param('search_term') . "\%";
            $sth  = $dbh->prepare(
                "select ID, DISCOUNT, DCD, TITLE, PRICE,
					 ISBN, URL_SMALL, UPC_1 from books where TITLE like ? ;"
              )
              || die "can't prep:$!";

        }
        $sth->execute($term) || die "can't select titles:$!";
        my @titles;
        while ( my $title = $sth->fetchrow_hashref ) {
            push( @titles, $title );
        }
        if ( $sth2 && ( @titles < 1 ) ) {
            $sth2->execute($term) || die "can't select titles:$!";
            while ( my $title = $sth2->fetchrow_hashref ) {
                push( @titles, $title );
            }

        }

        my $results = @titles;
        $template->param(
            RESULTS => $results,
            MESSAGE => "results for <b>"
              . $q->param('search_term')
              . $q->param('upc')
              . $q->param('isbn') . "</b>",
            TITLES => \@titles
        );
    }
    else {
    }
    $template->param( $self->session->param_hashref() );
    print $template->output();
    exit;
}

sub club_search {
    #use Business::ISBN qw(ean_to_isbn is_valid_checksum);
    use Net::Amazon;
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $id   = $q->param('id');
    my $book_title;
    my $book_price;
    my $upc = $q->param('upc');
    $upc =~ s/\W//g;
    $upc = substr( $upc, 0, 13 );
    my $isbn;

    if ( is_valid_checksum($upc) eq Business::ISBN::GOOD_ISBN ) {
        $isbn = $upc;
        $upc  = '';
    }
    else {
        $isbn = $q->param('isbn') || ean_to_isbn($upc);

    }
    my $book_price;
    my $book_title;
    my $info;
    my $img_url;
    my $sth5 = $dbh->prepare("select * from books where isbn = ?");
    my $sth6 = $dbh->prepare( "insert into books values(NULL,NULL,?,?,?,?,?,?,?,?)") || warn "can't prep:$!" ;
    if ( is_valid_checksum($isbn) eq Business::ISBN::GOOD_ISBN ) {
	$sth5->execute($isbn) || die "can't execute isbn search" . $sth5->errstr;
    	unless ($sth5->rows){
        	my $ua       = Net::Amazon->new( token => '1HNDXRF1YQR9X54K9R02',  secret_key => 'eWIPQ1bscu/AhDQQ3QLCMCRnXah30QhmovqgZKbk'  );
        	my $response = $ua->search( asin       => $isbn );
        	for ( $response->properties ) {
            		$book_title = $_->ProductName();
            		$book_price = $_->ListPrice();
            		$info = $_->authors();
			$img_url    = "/isbn?isbn=$isbn";
            		$book_price =~ s/\$//;
		}
		$sth6->execute($book_title,$book_price,$isbn,$upc,$info,1,1,0) || die "can't insert book" . $sth6->errstr;
	}else{
	 	my $book = $sth5->fetchrow_hashref;
		$book_title = $book->{'title'};
		$book_price = $book->{'price'};
		$img_url    = "/isbn?isbn=$isbn";
		
	}
    }
    else {
        $book_title = "BAD UPC? TRY ISBN";
    }
    my $sth2 = $dbh->prepare(
        "select name, email, phone, zip, 
			credit from book_club where id=\"$id\""
    );
    $sth2->execute();
    my ( $customer, $email, $phone, $zip, $credit ) = $sth2->fetchrow_array;
    my $sth4 =
      $dbh->prepare(
"select note, id as note_id from notes where customer_id=\"$id\" order by note_id desc"
      );
    $sth4->execute();
    while ( my $note = $sth4->fetchrow_hashref ) {
        $note->{"id"} = $id;
        $note->{"id"} = $id;
        push( @notes, $note );
    }
    my $template = $self->load_tmpl( 'member_info.tmpl.html', cache => 1 );
    $template->param(
        id         => $id,
        phone      => $phone,
        zip        => $zip,
        email      => $email,
        login      => $customer,
        credit     => $credit,
        book_price => $book_price,
        length     => $length,
        isbn       => $isbn,
        img_url    => $img_url,
        book_title => $book_title,
        upc        => $upc,
        NOTES      => \@notes
    );
    $template->param( $self->session->param_hashref() );
    print $template->output();
    exit;

}

sub club_search_old {
    #use Business::ISBN qw(ean_to_isbn);
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $id   = $q->param('id');
    my $book_title;
    my $book_price;
    my $upc;
    $term = $q->param('search_term');
    $term =~ s/\s//g;
    $sth = $dbh->prepare(
        "select TITLE as book_title, PRICE as book_price
		  from books where UPC_1  = ? ;"
      )
      || die "can't prep:$!";
    $sth->execute($term) || die "can't select titles:$!";
    ( $book_title, $book_price ) = $sth->fetchrow_array;
    my $sth2 =
      $dbh->prepare(
        "select name, email, phone, zip, credit from book_club where id=\"$id\""
      );
    $sth2->execute();
    my ( $customer, $email, $phone, $zip, $credit ) = $sth2->fetchrow_array;
    my $sth4 =
      $dbh->prepare(
"select note, id as note_id from notes where customer_id=\"$id\" order by note_id desc"
      );
    $sth4->execute();

    while ( my $note = $sth4->fetchrow_hashref ) {
        $note->{"id"} = $id;
        push( @notes, $note );
    }
    my $template = $self->load_tmpl( 'member_info.tmpl.html', cache => 1 );
    $template->param(
        id         => $id,
        phone      => $phone,
        zip        => $zip,
        email      => $email,
        login      => $customer,
        credit     => $credit,
        book_price => $book_price,
        book_title => $book_title,
        upc        => $term,
        NOTES      => \@notes
    );
    print $template->output();
    exit;

}

sub update_book {
    my $self  = shift;
    my $q     = $self->query();
    my $dbh   = $self->{dbh};
    my $id    = $q->param('id');
    my $title = $q->param('title');
    my $isbn  = $q->param('isbn');
    my $price = $q->param('price');
    my $upc_1 = $q->param('upc_1');
    my $upc_2 = $q->param('upc_2');
    my $info  = $q->param('info');
    $upc_1 =~ s/\s//g;
    $upc_2 =~ s/\s//g;
    $isbn  =~ s/\s//g;
    my $sth =
      $dbh->prepare(
"update books set title=?, isbn=?, price=?, upc_1=?, upc_2=?, info=? where id=?"
      )
      or die "cant prep";
    $sth->execute( $title, $isbn, $price, $upc_1, $upc_2, $info, $id )
      || die "can't update book:" . $sth->errstr;
    $self->detail();
    exit;
}

sub compose_email {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $id   = $q->param('id');
}

sub orders {
    my $self        = shift;
    my $q           = $self->query();
    my $dbh         = $self->{dbh};
    my $inv_limit   = $q->param('inv_limit') || 6;
    my $order_limit = $q->param('order_limit') || 3;
    my $template    = $self->load_tmpl( 'orders.tmpl.html', cache => 1 );
    my $sth         =
      $dbh->prepare(
"select distinct batchno as order_form from orders order by batchno desc limit $order_limit"
      )
      or die "cant prep";
    my $sth2 =
      $dbh->prepare(
"select date, invoice_id, dcd_cust_id, sum(inv_amt) as inv_total from invoices group by invoice_id  order by date desc, dcd_cust_id asc limit $inv_limit"
      )
      or die "cant prep";
    $sth->execute();
    $sth2->execute();
    my @order_forms;

    while ( my $form = $sth->fetchrow_hashref ) {
        push( @order_forms, $form );
    }
    my @invoices;
    while ( my $invoice = $sth2->fetchrow_hashref ) {
        chop $invoice->{inv_total};
        chop $invoice->{inv_total};
        push( @invoices, $invoice );
    }

    $template->param(
        ORDER_FORMS => \@order_forms,
        INVOICES    => \@invoices,
        INV_LIMIT   => $inv_limit,
        ORDER_LIMIT => $order_limit
    );
    $template->param( $self->session->param_hashref() );
    print $template->output();
    exit;

}

sub order_form {
    #use POSIX qw(ceil);
    my $self         = shift;
    my $q            = $self->query();
    my $dbh          = $self->{dbh};
    my $limit        = $q->param('limit') || 0;
    my @update_items = $q->param('itemno');
    my $jump_item    = ( $q->param('jump_item') ) || ( $limit + 1 );
    $limit = ( $jump_item - 1 );
    my $max  = $q->param('max') || 1;
    my $next = ( $limit + $max );
    my $prev = ( $limit - $max );
    $prev = 0 if ( $prev < 0 );
    my $batchno = $q->param('order_form');

#my $sth =  $dbh->prepare("select vendor.name as vendorname,
#orders.adult, orders.pagenumber from orders, vendor, discounts, category where batchno = ? and
    my $sth = $dbh->prepare(
        "select 
		orders.itemdescription,orders.hijinx_id,orders.issue, orders.vendor as vendorid,
		 discounts.discount as discountcode, 
		orders.price,orders.qty, category.name as category, orders.previews_description, orders.itemno, 
		orders.offeredagain, orders.resolicited, orders.maxissue, orders.mature,
		orders.caution1, orders.caution2, orders.caution3, orders.caution4,
		orders.adult, orders.pagenumber, orders.parentitem as parentitem from orders,  discounts, category where batchno = ? and 
		orders.discountcode = discounts.id and orders.category = category.id
		and linenum > $limit  order by linenum limit $max"
      )
      || die "can't prep: $!";
    my $sth2 = $dbh->prepare("update orders set qty = ? where itemno = ?")
      || die "can't prep: $!";
    my $sth3 = $dbh->prepare(
        "select count(subscriptions.title) as subscribers from subscriptions, 
				customers where title = ? and customers.frozen = 0 
				and subscriptions.customer = customers.id"
      )
      || die "can't prep: $!";
    my $sth4 =
      $dbh->prepare(
"select sum(qty * price) as total_retail from orders where qty > 0 and batchno = ?"
      );
    my $sth5 = $dbh->prepare("select name from vendor where id = ?");
    $sth->execute($batchno) || die "can't execute:$!";
    my @items;

    while ( my $item = $sth->fetchrow_hashref ) {
        if ( $item->{hijinx_id} > 0 ) {
            $sth3->execute( $item->{hijinx_id} ) || die "can't execute:$!";
            $sth5->execute( $item->{vendorid} )  || die "can't execute:$!";
            my $vendor = $sth5->fetchrow_hashref;
            $item->{vendorname} = $vendor->{name};
            my $count = $sth3->fetchrow_hashref;
            $item->{subscribers} = $count->{subscribers};
        }
        else {
            $item->{subscribers} = 0;
            $sth5->execute( $item->{vendorid} ) || die "can't execute:$!";
            my $vendor = $sth5->fetchrow_hashref;
            $item->{vendorname} = $vendor->{name};
        }
    	$item->{prefix} = substr($item->{itemno},0,5);
        if (length($item->{parentitem}) == 0 ){$item->{new} = 1};
        push( @items, $item );
    }
    foreach my $update_item (@update_items) {
        my $itemno = $update_item;
        my $qty    = $q->param("qty_$update_item");
        $sth2->execute( $qty, $update_item ) || die "can't execute:$!";
        warn "$update_item $qty,";
    }
    $sth4->execute($batchno) || die "can't execute:$!";
    my $row          = $sth4->fetchrow_hashref();
    my $total_retail = $row->{total_retail};
    my $template     = $self->load_tmpl(
        'order_form.tmpl.html',
        cache             => 1,
        die_on_bad_params => 0
    );
    $template->param(
        ITEMS        => \@items,
        limit        => $limit,
        max          => $max,
        next         => $next,
        jump_item    => $jump_item,
        prev         => $prev,
        order_form   => $batchno,
        total_retail => $total_retail
    );
    $template->param( $self->session->param_hashref() );
    print $template->output();
    exit;

}

sub list_order {
    my $self       = shift;
    my $q          = $self->query();
    my $dbh        = $self->{dbh};
    my $order_form = $q->param('order_form');
    my $skipped    = $q->param('skipped') || 0;
    my $sortby     = $q->param('sortby') || "itemno";
    my $sth;
    if ( $skipped > 0 ) {
        $sth = $dbh->prepare(
"select qty, itemno, linenum, category, price, discountcode, batchno,
			 (qty * price) as line_total, itemdescription, oicdate, shipdate,  hijinx_id, parentitem,
			itemno, issue from orders where qty = 0 and category = $skipped and parentitem = 0
			 and batchno = ? order by ?"
          )
          || die "can't prep sth:$!";
    }
    else {
        $sth = $dbh->prepare(
"select qty, itemno, linenum, category, price, discountcode, batchno,
                         (qty * price) as line_total, itemdescription, oicdate, shipdate,  hijinx_id,
                        itemno, issue from orders where qty > 0 and batchno = ? order by $sortby"
          )
          || die "can't prep sth:$!";
    }
    my $sth2;
    $sth2 =
      $dbh->prepare(
"select sum(qty * price) as total_retail from orders where qty > 0 and batchno = ?"
      );
    my $sth3 = $dbh->prepare(
"select category.name as catname, sum(qty*price) as cat_retail from orders, category 
				where batchno = ?  and category.id = orders.category 
				group by catname order by cat_retail desc "
    );
    my $sth4 = $dbh->prepare(
"select vendor.name as vendorname, sum(qty*price) as vendor_retail from orders, vendor where 
				 batchno = ? and orders.qty > 0 and vendor.id = orders.vendor 
				 group by vendorname order by vendor_retail desc"
    );
    #$sth->execute( $order_form, $sortby ) || die "can't execute:$!";
    $sth->execute( $order_form ) || die "can't execute:$!";
    $sth2->execute($order_form) || die "can't execute:$!";
    $sth3->execute($order_form) || die "can't execute sth3:$!";
    $sth4->execute($order_form) || die "can't execute sth4:$!";
    my @orders;

    while ( my $order = $sth->fetchrow_hashref ) {
        push( @orders, $order );
    }
    my $row          = $sth2->fetchrow_hashref();
    my $total_retail = $row->{total_retail};
    my @cats;
    while ( my $cat = $sth3->fetchrow_hashref ) {
        push( @cats, $cat );
    }
    my @vendors;
    while ( my $vendor = $sth4->fetchrow_hashref ) {
        push( @vendors, $vendor );
    }
    my $template = $self->load_tmpl(
        'list_order.tmpl.html',
        cache             => 1,
        die_on_bad_params => 0
    );
    $template->param(
        ORDERS       => \@orders,
        VENDORS      => \@vendors,
        CATS         => \@cats,
        total_retail => $total_retail,
        order_form   => $order_form,
        skipped      => $skipped
    );
    $template->param( $self->session->param_hashref() );
    print $template->output();
    exit;

}

sub export_order {
    my $self       = shift;
    my $q          = $self->query();
    my $dbh        = $self->{dbh};
    my $order_form = $q->param('order_form');
    my $sth        =
      $dbh->prepare(
"select qty,itemdescription, itemno from orders where qty > 0 and batchno = ? order by itemno"
      );
    $sth->execute($order_form) || die "can't execute:$!";
    my @orders;
    while ( my $order = $sth->fetchrow_hashref ) {
        push( @orders, $order );
    }
    my $template = $self->load_tmpl(
        'export_order.tmpl.html',
        cache             => 1,
        die_on_bad_params => 0
    );
    $template->param( ORDERS => \@orders );
    print $q->header( -type => 'text/plain' );
    print $template->output();
    exit;
}

sub drawers {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $sth;
    my $type = $q->param('type') || "open";
    if ( $type eq "open" ) {
        $sth =
          $dbh->prepare(
            "select * from drawers where close_date = '0000-00-00 00:00:00'");
    }
    else {
        $sth = $dbh->prepare("select * from drawers");
    }
    $sth->execute() || die;
    my @drawers;
    while ( my $drawer = $sth->fetchrow_hashref ) {
        push( @drawers, $drawer );
    }
    my $template = $self->load_tmpl(
        'cash/drawers.tmpl.html',
        cache             => 1,
        die_on_bad_params => 0
    );
    $template->param( DRAWERS => \@drawers );
    print $q->header( -type => 'text/html' );
    print $template->output();
    exit;
}

sub new_drawer {
    my $self         = shift;
    my $q            = $self->query();
    my $dbh          = $self->{dbh};
    my $open_balance = $q->param('open_balance') || 0;
    $dbh->do(
"INSERT INTO `drawers` ( `id` , `cashier_id` , `open_date` , `close_date` , `open_balance` , `closing_cash_balance` , `closing_chg_balance` , `closing_chk_balance` , `closing_credit_balance` , `notes` )
VALUES ( '', '0', now(), '', $open_balance, '0.00', '0.00', '0.00', '0.00', '')"
    );
    $self->drawers();
    exit;
}

sub close_drawer {
    my $self      = shift;
    my $q         = $self->query();
    my $dbh       = $self->{dbh};
    my $drawer_id = $q->param('drawer_id');
    $dbh->do("update drawers set close_date = now() where id = $drawer_id");
    $self->drawers();
    exit;

}

sub oic {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my ( $today, $last );
    if ( $q->param("date") ) {
        $today = $q->param("date");
    }
    else {
        $gmt = gmtime();
        my ( $year, $month, $day ) = Today($gmt);
        if ( $month < 10 ) { $month = 0 . $month }
        if ( $day < 10 )   { $day   = 0 . $day }
        $today = "$year-$month-$day";
    }
    $sth = $dbh->prepare(
        "select qty, itemno, linenum, category, price, discountcode, batchno,
		 (qty * price) as line_total, itemdescription, oicdate, shipdate,  hijinx_id,
		itemno, issue from orders where oicdate >= ? and category < 5 order by oicdate asc, 
		itemdescription asc"
      )
      || die "can't prep sth:$!";
    my $sth2 = $dbh->prepare(
        "select count(*) from subscriptions, customers where 
				subscriptions.customer = customers.id and customers.frozen=0
				 and subscriptions.title  = ?"
    );
    $sth->execute($today) || die "can't execute:$!";
    my @orders;
    while ( my $order = $sth->fetchrow_hashref ) {
        $order->{'subs'} = 0;
        my $color = 'white';
        if ( $order->{'hijinx_id'} > 0 ) {
            $sth2->execute( $order->{'hijinx_id'} );
            my @subs = $sth2->fetchrow_array;
            $order->{'subs'} = $subs[0];
            if ( $order->{'subs'} == $order->{'qty'} ) {
                $color = 'gray';
            }
            elsif ( $order->{'subs'} > $order->{'qty'} ) {
                $color = 'red';
            }
            elsif ( ( $order->{'qty'} - $order->{'subs'} ) <= 3 ) {
                $color = 'lightgray';
            }
            elsif ( ( $order->{'qty'} - $order->{'subs'} ) >= 10 ) {
                $color = 'orange';
            }
            $order->{'color'} = $color;
        }
        push( @orders, $order );
    }
    my $template =
      $self->load_tmpl( 'oic.tmpl.html', cache => 1, die_on_bad_params => 0 );
    $template->param( TODAY => $today, ORDERS => \@orders );
    print $template->output();
    exit;
}

sub graphs {
    my $self     = shift;
    my $q        = $self->query();
    my $template = $self->load_tmpl( 'graphs.tmpl.html', cache => 1 );
    $template->param( $self->session->param_hashref() );
    print $template->output();
    exit;
}

sub email {
    my $self     = shift;
    my $q        = $self->query();
    my $dbh      = $self->{dbh};
    my $template = $self->load_tmpl( 'email.tmpl.html', cache => 1 );
    $template->param( $self->session->param_hashref() );
    print $template->output();
    exit;
}

sub view_invoice {
    my $self     = shift;
    my $q        = $self->query();
    my $dbh      = $self->{dbh};
    my $template = $self->load_tmpl(
        'view_invoice.tmpl.html',
        cache             => 1,
        die_on_bad_params => 0
    );
    my $invoice_id = $q->param('invoice_id');
    my $order_by   = $q->param('order_by') || "descr";
    my $sth        = $dbh->prepare(
        "select line_id, qty, descr, itemno, retail_price, unit_price,
			inv_amt, cat_id, order_type, discount, isbn,  po_no, hijinx_id, batchno, 
			linenum  from invoices where invoice_id = ? order by $order_by, descr"
    );
    my $sth2 =
      $dbh->prepare(
        "select hijinx_id, batchno, linenum from orders where itemno = ?" );
    my $sth3 =
      $dbh->prepare(
" select category.name as catname, invoices.isbn as isbn, category.id as cat_id, sum(invoices.qty * invoices.retail_price) as cat_retail from invoices, category where invoices.invoice_id = ? and category.id =  invoices.cat_id group by catname order by cat_retail desc"
      );
    my $sth4 = $dbh->prepare(
"select vendor.name as vendorname, sum(qty*price) as vendor_retail from orders, vendor where 
				 batchno = ? and orders.qty > 0 and vendor.id = orders.vendor 
				 group by vendorname order by vendor_retail desc"
    );
    $sth->execute($invoice_id) || die "can't execute";
    my @lines;
    my $total_cost   = 0;
    my $total_retail = 0;

    while ( my $line = $sth->fetchrow_hashref ) {
        $total_cost += $line->{inv_amt};
        $line->{color} = "#FFFFFF";
        if ( $line->{cat_id} == 3 ) {
            $line->{color} = "#99CCFF";
        }
        elsif ( $line->{cat_id} == 1 ) {
            $line->{color} = "#99FFCC";
        }
        $total_retail += ( $line->{qty} * $line->{retail_price} );
        push( @lines, $line );
    }
    $sth3->execute($invoice_id) || die "can't execute";
    my @cats;
    while ( my $cat = $sth3->fetchrow_hashref ) {
        $cat->{color} = "#FFFFFF";
        if ( $cat->{cat_id} == 3 ) {
            $cat->{color} = "#99CCFF";
        }
        elsif ( $cat->{cat_id} == 1 ) {
            $cat->{color} = "#99FFCC";
        }
        $total_retail += ( $line->{qty} * $line->{retail_price} );
        my $percentage_of_invoice =
          ( ( $cat->{cat_retail} / $total_retail ) * 100 );
        $percentage_of_invoice = substr( $percentage_of_invoice, 0, 5 );
        $cat->{percentage} = $percentage_of_invoice;
        push( @cats, $cat );
    }
    $template->param(
        LINES        => \@lines,
        CATS         => \@cats,
        TOTAL_COST   => $total_cost,
        INVOICE_ID   => $invoice_id,
        TOTAL_RETAIL => $total_retail,
    );
    $template->param( $self->session->param_hashref() );
    print $template->output();
    exit;
}

sub ajax {
    my $self     = shift;
    my $q        = $self->query();
    my $dbh      = $self->{dbh};
    my $template = $self->load_tmpl( 'ajax.tmpl.html', cache => 1 );
    $template->param( $self->session->param_hashref() );
    print $template->output();
    exit;
}

sub multiply {

    # grab arguments
    my $self = shift;

    # declare variables
    my $cgi    = $self->query();
    my @rsargs = $cgi->param('rsargs');
    my $num1   = $rsargs[0];
    my $num2   = $rsargs[1];

    # multiple
    my $value = $num1 * $num2;

    # return the value
    return "+:$value\n";
}

sub ajax_rem_this_week {

    # grab arguments
    my $self     = shift;
    my $dbh      = $self->{dbh};
    my $q        = $self->query();
    my @rsargs   = $q->param('rsargs');
    my $title_id = $rsargs[1];
    my $sth      = $dbh->prepare("delete from this_week where id = ?")
      or die "cant prep";
    $sth->execute($title_id) || warn "can't delete title: $title_id";
    exit;
}

sub divide {

    # grab arguments
    my $self     = shift;
    my $cgi      = $self->query();
    my @rsargs   = $cgi->param('rsargs');
    my $title_id = $rsargs[0];

    # declare variables
    my $cgi    = $self->query();
    my @rsargs = $cgi->param('rsargs');
    my $num1   = $rsargs[0];
    my $num2   = $rsargs[1];

    # return error if $num2 = 0
    return '-:Can not divide by zero' unless ($num2);

    # divide
    my $value = $num1 / $num2;

    # return the value
    return "+:$value\n";
}

sub rcv_inv {
    my $self       = shift;
    my $q          = $self->query();
    my $invoice_id = $q->param('invoice_id');
    my $dbh        = $self->{dbh};
    my ( $date, $dcd_cust_id );
    my @invoice_lines;
    my $sth = $dbh->prepare(
"select invoices.line_id, invoices.qty, invoices.descr, invoices.itemno, invoices.retail_price, 
			category.name as cat_id, invoices.po_no as po_no, invoices.hijinx_id, invoices.batchno, invoices.received,
			invoices.damages, invoices.dcd_cust_id, invoices.date, invoices.isbn,
			invoices.linenum  from invoices, category where invoice_id = ? and invoices.cat_id = category.id 
			order by descr asc"
    );

    if ( $q->param('update') == 1 ) {
        @invoice_lines = $q->param('line_id');
        my $sth2 =
          $dbh->prepare(
"update invoices set received = ?, damages = ? where line_id = ? and invoice_id = ?"
          );
        foreach my $line_item (@invoice_lines) {
            my $damages  = $q->param("dmgd_$line_item");
            my $received = $q->param("rcvd_$line_item");
            $sth2->execute( $received, $damages, $line_item, $invoice_id )
              || warn "can't update: $line_item";
        }
    }

    $sth->execute($invoice_id) || warn "can't execute";
    my @lines;
    while ( my $line = $sth->fetchrow_hashref ) {
        $date        = $line->{date};
        $dcd_cust_id = $line->{dcd_cust_id};
        chop $line->{retail_price};
        chop $line->{retail_price};
        my $linecolor = 'white';
        if ( $line->{qty} == $line->{received} ) {
            $linecolor = "lightgray";
        }
        $line->{color} = $linecolor;
        push( @lines, $line );
    }
    my $template = $self->load_tmpl(
        'rcv_inv.tmpl.html',
        cache             => 1,
        die_on_bad_params => 0,
    );
    $template->param(
        LINES       => \@lines,
        INVOICE_ID  => $invoice_id,
        DCD_CUST_ID => $dcd_cust_id,
        DATE        => $date,
    );
    print $template->output();
    exit;
}

sub osd {
    my $self       = shift;
    my $q          = $self->query();
    my $invoice_id = $q->param('invoice_id');
    my $dbh        = $self->{dbh};
    my $sth        = $dbh->prepare(
        "select itemno, descr, qty as ordered, (qty - received) as short 
				from invoices where received < qty and invoice_id = ?"
    );
    my $sth2 = $dbh->prepare(
        "select itemno, descr, qty as ordered, (received - qty) as over 
				from invoices where received > qty and invoice_id = ?"
    );
    my $sth3 = $dbh->prepare(
        "select itemno, descr, qty as ordered, damages 
				from invoices where damages > 0 and invoice_id = ?"
    );
    my $sth4 = $dbh->prepare(
        "select distinct dcd_cust_id as dcd_cust_id, date as date from invoices
					where invoice_id = ?"
    );
    $sth4->execute($invoice_id) || warn "can't execute";
    $sth->execute($invoice_id)  || warn "can't execute";
    $sth2->execute($invoice_id) || warn "can't execute";
    $sth3->execute($invoice_id) || warn "can't execute";
    my @shortages;
    while ( my $line = $sth->fetchrow_hashref ) {
        push( @shortages, $line );
    }
    my @overages;
    while ( my $line = $sth2->fetchrow_hashref ) {
        push( @overages, $line );
    }
    my @damages;
    while ( my $line = $sth3->fetchrow_hashref ) {
        push( @damages, $line );
    }
    my ( $dcd_cust_id, $date );
    while ( my $line = $sth4->fetchrow_hashref ) {
        $dcd_cust_id = $line->{dcd_cust_id};
        $date        = $line->{date};
    }
    my $template =
      $self->load_tmpl( 'osd.tmpl.html', cache => 1, die_on_bad_params => 0, );
    $template->param(
        DAMAGES     => \@damages,
        OVERAGES    => \@overages,
        SHORTAGES   => \@shortages,
        DCD_CUST_ID => $dcd_cust_id,
        DATE        => $date,
        INVOICE_ID  => $invoice_id,
    );
    print $template->output();
    exit;
}

sub get_title_id {
	#returns existing title_id or create one and returns it
    my $self = shift;
	my $title = shift;
    my $dbh  = $self->{dbh};
    my $sth = $dbh->prepare("select id from titles where name = ?")
      || die "can't prep sth:$!";
	my $status = $sth->execute($title);
	if ( $status == 1 ) {
		#title exists
		my $id = $sth->fetchrow_array;
		return $id;
	}else{
		#title doesn't exist
		return 0;
	}
}

sub issue_exists {
	my $self = shift;
	my $title_id = shift;
	my $issue = shift;
    	my $dbh  = $self->{dbh};
    	my $sth = $dbh->prepare("select issue from cycles where title_id = ? and issue = ?")
      || die "can't prep sth:$!";
	my $status = $sth->execute($title_id, $issue);
	if ( $status == 1 ) {
		#issue exists
		my $issue = $sth->fetchrow_array;
		return $issue;
	}else{
		#issue doesn't exist
		return "no issue";
	}

}


sub import_customers {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $file     = $q->upload("customers.tsv") || croak "need file";
    my $gmt          = gmtime();
    my ( $year, $month, $day ) = Today($gmt);
    $year =~ s/\d\d(\d\d)/$1/;
    if ( $month < 10 ) { $month = 0 . $month }
    if ( $day < 10 )   { $day   = 0 . $day }
    my $today = $year . $month . $day;
	my $frozen = 0;
    my $sth   = $dbh->prepare("insert into customers values(?,?,?,?,?,?,?,?)")
      or die "cant prep";
    foreach (<$file>) {
		chomp;
		s/\"//g;
		my ($new_customer, $phone, $email, $zip, $address) = split /\t/;
		chomp($email);
    	$sth->execute( undef, $new_customer, $email, $phone, $today, $frozen, $zip, $address )
      		|| croak "can't insert new customer:" . $sth->errstr;
	}
	$q->param( -name => 'letter', -value => 'a' );
	$self->list_customers();
    exit;
}

sub import_raw_isbn {
    #use Business::ISBN qw(ean_to_isbn is_valid_checksum);
    use Net::Amazon;
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $file     = $q->upload("isbn.txt");
    my $sth = $dbh->prepare( "select *  from books where isbn = ? ;") || die "can't prep:$!";
    my $sth2 = $dbh->prepare( "insert into books values(NULL,?,?,?,?,?,?,?,?,?)") || warn "can't prep:$!" ;
    my $sth3 = $dbh->prepare( "update books set in_stock = in_stock + 1  where isbn = ?  ")
      or die "cant prep";
    foreach (<$file>) {
		chomp;
		my ($upc, $item_code, $title, $issue, $price,$isbn);
		$upc = $_;
    	$upc =~ s/\W//g;
    	$upc = substr( $upc, 0, 13 );
	    if ( is_valid_checksum($upc) eq Business::ISBN::GOOD_ISBN ) {
			$isbn = $upc;
	    } else {
			$isbn = Business::ISBN::ean_to_isbn($upc) || carp "$upc $!";
	    }
		$sth->execute($isbn) || die "can't execute search" . $sth->errstr;
		unless ($sth->rows){
			#not in db, lookup and do insert
			if ( is_valid_checksum($isbn) eq Business::ISBN::GOOD_ISBN ) {
				$dcd = `/home/dan/cpro.hijinxcomics.com/hijinx/util_scripts/isbn2dcd.pl $isbn` || warn "cant get dcd with isbn2dcd.pl:$!";
				my $ua       = Net::Amazon->new( token => '1HNDXRF1YQR9X54K9R02', secret_key => 'eWIPQ1bscu/AhDQQ3QLCMCRnXah30QhmovqgZKbk')|| die;
				my $response = $ua->search( asin       => $isbn );
				my ( $info, $title, $price, $info);
				if ($response->is_success()){
					for ( $response->properties ) {
						$title = $_->ProductName();
						$price = $_->ListPrice();
						$info = $_->authors();
						$price =~ s/\$//;
					}
					$sth2->execute($dcd,$title,$price,$isbn,$upc,$info,0,0,0) 
						|| warn "can't add new book $isbn $title" . $sth2->errstr;
				}
			}
		}
		#update here
		$sth3->execute($isbn) || warn "can't add in_stock to $isbn" . $sth3->errstr;
	}
		$self->books();
    exit;
}

sub import_books {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $file     = $q->upload("isbn.csv");
    my $sth   = $dbh->prepare("insert into books values(NULL,?,?,?,?,NULL,NULL,0,0,0)")
      or die "cant prep";
    foreach (<$file>) {
		chomp;
		my ($item_code, $title, $issue, $price,$isbn) = split /,/;
    	$isbn =~ s/\W//g;
    	$sth->execute($item_code, $title, $price,$isbn )
      		|| warn "can't insert new customer:" . $sth->errstr;
	}
	$self->books();
    exit;
}
sub customers {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $template =
      $self->load_tmpl( 'customers.tmpl.html', cache => 1, die_on_bad_params => 0, );
    print $template->output();
    exit;
}

sub suggest{
    my $self = shift;
    my $dbh  = $self->{dbh};
	my $isbn = shift;
        my $default_id = $self->param(default_id) || 0;
	my $sth = $dbh->prepare("select distinct customer_id from notes where isbn = ? and customer_id != $default_id and customer_id != 1278" ); # 476 is the default member 1278 = comicbookshelf.com
	my $sth2 = $dbh->prepare("select distinct isbn from notes where notes.customer_id = ? and isbn > 0");
	my $sth3 = $dbh->prepare("select title, isbn from books where isbn = ?");

	$sth->execute($isbn) || die "can't do it" ;
	my %books;
	my @suggestions;
        my $count;
	while(my $customer = $sth->fetchrow_hashref){
		$count++;
		$sth2->execute($customer->{"customer_id"})|| die "can't get last checkin: $!";
		while(my $book = $sth2->fetchrow_hashref){
			$books{$book->{"isbn"}}++ ;
		}
	}


	foreach $key (sort { $books{$b} <=> $books{$a} } keys %books){
		unless ($key eq $isbn || $books{$key} == 1 ){
			$sth3->execute($key) || die "can't do it" ;
			my $title;
			while(my $sugg = $sth3->fetchrow_hashref){
                                my $percent;
				if($count){
					$percent = $books{$key} / $count * 100;
					$percent =~ s/\..*//;

				}
				$sugg->{title} = " $percent\% " .  $sugg->{title} . " (+$books{$key})";
				push (@suggestions,$sugg);
			}
		}
	}
	return \@suggestions;
}

sub hashvalsort{
	$books{$b} <=> $books{$a};
}
sub multi {
    my $self = shift;
    my $q    = $self->query();
    my @checked   = $q->param('checked') ;
    #croak  @checked . "don't work!"; 
    my $action = $q->param('action') || croak "must specify action";
    my $dbh  = $self->{dbh};
    my $sth;
    if ($action eq 'delete'){
        $sth = $dbh->prepare("delete from titles where id = ?");
    }elsif ($action eq 'archive'){
        $sth = $dbh->prepare("update titles set archived = 1 where id = ?");
    }elsif ($action eq 'unarchive'){
        $sth = $dbh->prepare("update titles set archived = 0 where id = ?");
    }elsif ($action eq 'pow'){
	my $type = "comic";
	my $tag = "pow";
        $sth = $dbh->prepare("insert into tags values(?,'comic','pow')") || croak $sth->errstr ;
    }elsif ($action eq 'pow2'){
	my $type = "comic";
	my $tag = "pow2";
        $sth = $dbh->prepare("insert into tags values(?,'comic','pow2')") || croak $sth->errstr ;
    }elsif ($action eq 'pow3'){
	my $type = "comic";
	my $tag = "pow3";
        $sth = $dbh->prepare("insert into tags values(?,'comic','pow3')") || croak $sth->errstr ;
    }elsif ($action eq 'pow4'){
	my $type = "comic";
	my $tag = "pow4";
        $sth = $dbh->prepare("insert into tags values(?,'comic','pow4')") || croak $sth->errstr ;
    }elsif ($action eq 'pow5'){
	my $type = "comic";
	my $tag = "pow5";
        $sth = $dbh->prepare("insert into tags values(?,'comic','pow5')") || croak $sth->errstr ;
    }elsif ($action eq 'pow6'){
	my $type = "comic";
	my $tag = "pow6";
        $sth = $dbh->prepare("insert into tags values(?,'comic','pow6')") || croak $sth->errstr ;
    }elsif ($action eq 'unpow'){
        $sth = $dbh->prepare("delete from  tags where id = ? and type= 'comic'  and tag like 'pow%' ") || croak $sth->errstr ;
    }else{
        croak "that action is not recognized";
    }
    foreach my $id (@checked){
       $sth->execute($id) || croak "can't multi execute: " . $sth->errstr;
    }
    $self->list_titles();
    exit;
}
sub stub {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->{dbh};
    my $template = $self->load_tmpl( 'customers.tmpl.html', cache => 1, die_on_bad_params => 0, );
    print $template->output();
    exit;
}

sub report_doublestk {
    my $self = shift;
    my $dbh  = $self->{dbh};
    my $sth = $dbh->prepare("select title, isbn, id, in_stock, min, on_order from books where in_stock >= (min * 2) and in_stock > 0 order by title");
    my $sth2 = $dbh->prepare("select count(isbn) as sold from notes where isbn = ?");
    my @report_lines;
    $sth->execute() || croak "can't execute report";
    while (my $line = $sth->fetchrow_hashref){
	$sth2->execute($line->{isbn});
	($line->{sold}) = $sth2->fetchrow_array || "O";
        push (@report_lines, $line);
    }
    return \@report_lines;
}
sub report_booklist {
    my $self = shift;
    my $dbh  = $self->{dbh};
    my $sth = $dbh->prepare("select title, isbn, id, in_stock, min, on_order from books where in_stock > 0 order by title ");
    my $sth2 = $dbh->prepare("select count(isbn) as sold from notes where isbn = ?");
    my @report_lines;
    $sth->execute() || croak "can't execute report";
    while (my $line = $sth->fetchrow_hashref){
	$sth2->execute($line->{isbn});
	($line->{sold}) = $sth2->fetchrow_array || "O";
        push (@report_lines, $line);
    }
    return \@report_lines;
}
sub report_3plus {
    my $self = shift;
    my $dbh  = $self->{dbh};
    my $sth = $dbh->prepare("select title, isbn, id, in_stock, min, on_order from books where in_stock > 2 order by title");
    my @report_lines;
    $sth->execute() || croak "can't execute report";
    while (my $line = $sth->fetchrow_hashref){
        push (@report_lines, $line);
    }
    return \@report_lines;
}

sub report {
    my $self = shift;
    my $q    = $self->query();
    my $type = $q->param('type') || 'unknown';
    my $dbh  = $self->{dbh};
    my $report_title;
    if ($type eq '3plus'){
	$report_title = "3 or more copies";
	@report = $self->report_3plus();
    }elsif ($type eq 'doublestk'){
	$report_title = "in stock >= (min * 2)";
	@report = $self->report_doublestk();
    }elsif ($type eq 'booklist'){
	$report_title = "all in stock books";
	@report = $self->report_booklist();
    }else{
	$report_title = "unknown report title";
    }

    my $template = $self->load_tmpl( 'report.tmpl.html', cache => 1, die_on_bad_params => 0, );
    $template->param(
		REPORT_TITLE => $report_title,
		REPORT => @report,
		);
    print $template->output();
    exit;
}

sub changes{
    my $self = shift;
    my $namor = $self->{namor_db};
    if (! $namor){ croak "you don't have a Namor database configured"};
    my $dbh = $self->{dbh};
    my $q    = $self->query();
    my $sth = $namor->prepare("select * from changes order by timestamp desc limit 1000");
    my $sth2 = $dbh->prepare("select customers.name as customer, titles.name as title from customers, titles where customers.id = ? and titles.id = ?");
    $sth->execute() || croak "can't execute change search";
	my @changes;
	while (my $change = $sth->fetchrow_hashref){
		$change->{'timestamp'} = localtime( $change->{'timestamp'});
		$sth2->execute($change->{'customer'},$change->{'title'}) || croak "can't execute " . $sth2->errstr ;
		($change->{'customer_name'},$change->{'title_name'})  = $sth2->fetchrow_array();
		push @changes, $change;
	}
    my $template = $self->load_tmpl( 'changes.tmpl.html', cache => 1, die_on_bad_params => 0, );
	$template->param(CHANGES => \@changes);
    print $template->output();
    exit;
}

sub top_gns{
    my $self = shift;
    my $dbh = $self->{dbh};
    my $q    = $self->query();
    my $show = $q->param("show") || 100;
    my $year = $q->param("year");
    my $month = $q->param("month")  ;
    if ($show =~ /\D/){croak "numbers only"};
	my $sth;
    if ($year){
		if ($month){  #provided month and year
    		$sth = $dbh->prepare("select count(notes.isbn) as count, notes.isbn as isbn,  notes.note as note, books.dcd as dcd, books.title as title, books.price as price, books.min as min from notes, books where notes.isbn > 0 and notes.isbn = books.isbn and notes.note like '%$month\/%\/$year%' group by isbn order by count desc limit $show");
		}else{  #year but no month
    		$sth = $dbh->prepare("select count(notes.isbn) as count, notes.isbn as isbn,  notes.note as note, books.dcd as dcd, books.title as title, books.price as price, books.min as min  from notes, books where notes.isbn > 0 and notes.isbn = books.isbn and notes.note like '%\/%\/$year%' group by isbn order by count desc limit $show");
		}
	}else{ #no month or year
		$month = '';
    	$sth = $dbh->prepare("select count(notes.isbn) as count, notes.isbn as isbn,  notes.note as note, books.dcd as dcd, books.title as title, books.price as price, books.min as min from notes, books where notes.isbn > 0 and notes.isbn = books.isbn  group by isbn order by count desc limit $show");
	}
    $sth->execute() || croak "can't execute change search";
	my @books;
	while (my $book = $sth->fetchrow_hashref){
		push @books, $book;
	}
    my $template = $self->load_tmpl( 'top_gns.tmpl.html', cache => 1, die_on_bad_params => 0, );
	$template->param(BOOKS => \@books, 
					SHOW => $show,
					YEAR => $year,
					MONTH => $month);
    print $template->output();
    exit;
}
1
