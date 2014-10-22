#!/usr/bin/perl


my %instances = (
	'hijinx' => 'HIJINX01',
	#'demo' => 'HIJINX02',
	#'dev' => 'HIJINX03',
	#'test' => 'HIJINX04',
	#'mainstreet' => 'HIJINX05', #pays ??
	#'portal' => 'HIJINX06',  #pays $25 a month
	#'essential' => 'HIJINX07', #pays $25 a month
	'earth2' => 'HIJINX08',   #pays $30 a month
	'collpar' => 'HIJINX09',  #pays $30 a month
	'rook' => 'HIJINX12', #pays 30 a month
	#'littlerocket' => 'HIJINX11',
	#'3rdplanet' => 'HIJINX12',
	#'monkey' => 'HIJINX13',
);
my $instance_path = '/home/dan/cpro.hijinxcomics.com/cgi-bin/cpro_instances/';
foreach my $shop (sort keys %instances){
	chdir ($instance_path . $shop);
	print "backing up $shop : $instances{$shop}\n";
	system "mv $shop.sql.gz $shop.sql.gz.bak ";
	system "mysqldump -udan -pfoobar $instances{$shop} | gzip > $shop.sql.gz";
}

