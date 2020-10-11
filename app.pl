#!/usr/bin/env perl
use Dancer2;
use Dancer2::Plugin::Database;
use Dancer2::Plugin::REST;
use Dancer2::Plugin::Cache::CHI;
use LWP::UserAgent;
use Syntax::Keyword::Try;

# test handler to test if app is runned
get '/' => sub {
	status_ok({ok => 1});
};


# Just inits tables in DB
sub _init_db_schema {
	my @queries = (
		'CREATE TABLE IF NOT EXISTS images (
			id TEXT PRIMARY KEY,
			author TEXT,
			camera TEXT,
			full_picture TEXT,
			tags TEXT,
			cropped_picture TEXT
		)',
	);

	for my $query (@queries){
		database()->prepare($query)->execute;
	}
}
