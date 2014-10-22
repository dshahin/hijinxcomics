#!/usr/bin/perl

#   Copyright 2007 Daniel J Shahin
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; version 2 of the License.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.

use lib qw( /home/dan/usr/local/lib/perl5/site_perl/5.8.7/
 /home/dan/usr/local/lib/perl5/site_perl/5.8.5/
		/home/dan/cpro.hijinxcomics.com/hijinx);
use HTML::Template;
#uncomment for validated XML
use XML::Simple;
my $template = HTML::Template->new(filehandle=>*DATA  ) 
	|| die "can't open template $!\n";
my @headers;
my @items;
my ($date, $account_number, $generated_by, $invoice_type);

while(<>){
	chomp;
	s/\r//; #strip carriage returns
	s/\&/\&amp\;/g; #fix ampersands for xml conversion
	if ( $_ =~ /^\"/) { #if line starts with a quote
            s/\"//g;
            push @headers, $_;

	} elsif ( $_ =~ /^\d/ || $_ =~ /^\-/ ) {
            s/\"//g;
	    my %line;
                ($line{'units_shipped'},$line{'item_code'},   $line{'item_description'},  $line{'retail_price'},
                $line{'unit_price'},   $line{'invoice_amount'},  $line{'category_code'}, $line{'order_type'},
                $line{'processed_as'}, $line{'order_number'}, $line{'upc'},    $line{'isbn'},
                $line{'ean'},          $line{'po_number'},    $line{'allocated'})
              = split(/,/);
	    $line{'item_code'} =~ s/ //g;
	    $line{'processed_as'} =~ s/ //g;
	    $line{'discount_code'} = chop $line{'item_code'};
	    if ($line{'processed_as'} eq ""){
		$line{'processed_as'} = $line{'item_code'};
	    }
	    push (@items, \%line);
            $generated_by = $headers[0];
            $account_number = $headers[1];
            $invoice_type = $headers[2];
            $date = $headers[3];
            chomp ($date, $account_number,$invoice_type,$date);
	}


}
$items = \@items;
$template->param(ITEMS => $items,
		DATE => $date,
		GENERATED_BY => $generated_by,
		ACCOUNT_NUMBER => $account_number,
		INVOICE_TYPE => $invoice_type,
		);

$xml = $template->output;  #outputs unvalidated XML 

#run the template through XML::Simple to make sure xml is well-formed
#not strictly necessary, but good for debugging
my $ref = XMLin($xml, ForceArray=>1, KeepRoot=>1);
#$xml = XMLout($ref);

print $xml;
#print "code ", $ref->{'items'}->{'item'}->[0]->{'item-code'}, "\n";

#other ways to access data:
#print "item code: ", $ref->{'items'}->{'item'}->[0]->{'item-code'}, "\n";

#the following is the template we load into HTML::Template
#it can be put in a separate file if necessary
__DATA__
<diamond-invoice>
	<warehouse><TMPL_VAR NAME=generated_by></warehouse>
	<account-number><TMPL_VAR NAME=account_number></account-number>
	<invoice-type><TMPL_VAR NAME=invoice_type></invoice-type>
	<date><TMPL_VAR NAME=date></date> 
	<items><TMPL_LOOP NAME=items>
	<item>
		<description><TMPL_VAR NAME=item_description></description>
		<units-shipped><TMPL_VAR NAME=units_shipped></units-shipped>
		<item-code><TMPL_VAR NAME=item_code></item-code>
		<processed-as><TMPL_VAR NAME=processed_as></processed-as>
		<discount-code><TMPL_VAR NAME=discount_code></discount-code>
		<retail-price><TMPL_VAR NAME=retail_price></retail-price>
		<unit-price><TMPL_VAR NAME=unit_price></unit-price>
		<invoice-amount><TMPL_VAR NAME=invoice_amount></invoice-amount>
		<category><TMPL_VAR NAME=category_code></category>
		<order-type><TMPL_VAR NAME=order_type></order-type>
		<order-number><TMPL_VAR NAME=order_number></order-number>
		<upc><TMPL_VAR NAME=upc></upc>
		<isbn><TMPL_VAR NAME=isbn></isbn>
		<ean><TMPL_VAR NAME=ean></ean>
		<po-number><TMPL_VAR NAME=po_number></po-number>
		<allocated><TMPL_VAR NAME=allocated></allocated>
	</item> </TMPL_LOOP>
	</items>
</diamond-invoice>
