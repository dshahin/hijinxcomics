#!/usr/bin/perl

open OF, "order_form.txt" or die "can't open invoice\n";
while (<OF>){
	my @fields = split /\t/;
	my $item = $fields[1];
	$item =~ s/\"//g;
	my $path = "/home/dan/cpro.hijinxcomics.com/html/images/FEB07/thumbs/";
	my $filename = $path . $item . ".jpg";
	if (-e $filename){
		print "$item\n";
		next;
	}else{
		print "missing: $filename\n";
		system "cp ./cantfind.jpg $filename";
	}
}
