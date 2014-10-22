#!/usr/bin/perl 

# ./resizer.pl 150 DEC09/thumbs/*
#  ./resizer.pl 400 DEC09/large/*

use Image::Magick;
my $width = shift;

foreach(@ARGV){
	my $input =  $_;
	my($image, $x);
	$image = Image::Magick->new;
	$x = $image->Read($input);
	warn "$x" if "$x";
	$x = $image->Scale(geometry=>"$width");
	warn "$x" if "$x";

	print "resizing $_\n";
	$image->Write($input);
}

