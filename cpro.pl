#!/usr/bin/perl 
use lib qw(/home/danshahin/perlmods/share/perl/5.8.8/);
use Hijinx;
my $log = Hijinx->new( TMPL_PATH => '/home/danshahin/hijinx/templates',
				PARAMS =>{ 'database' => 'dbi:mysql:hijinx1:',
						'dbuser' => 'whoever',
						'dbpass' => 'whatever',
						'namor_db' => 'dbi:SQLite:dbname=/home/hijinx/hijinx.db',
						'storename' => 'hijinx',
						'longstorename' => 'Hijinx Comics',
						'default_id' => 476,
						'gcode' => 'UA-802705-4',
						'default_credit' => '5',
				},
				die_on_bad_params => 0);
$log->run();




