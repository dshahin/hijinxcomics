#!/usr/bin/perl

while (<>){
	s/"//g;
	my @line = split /,/;
	print "$line[2] $line[5] $line[11]\n";

}
