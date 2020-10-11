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

# To store image data DB is used. But to allow searching by meta
# some faster storage required. That is fo memcache. So just whe image data
# recieved it saved to DB. Meta tags parsed and stored to memcache. LInking
# between DB entry and cached meta done by image id.
sub _cache_image_data {
	my $image = shift;

    # collecting all meta tags in one list
	my @metas = grep {$_} split(/\s?#/, $image->{tags} // ''), split(/\s/, $image->{camera} // ''), split(/\s/, $image->{author} // '');

    # adding entry to cached lists
	for my $tag (@metas){
		my @entities = _unpack_cache_data(cache->get($tag) // '');
		push @entities, $image->{id};
		cache->set($tag, _pack_cache_data(@entities));
	}

	try {
        # creating entry in db
		database()->quick_insert( 'images', $image );
	} catch {
		die $@;
	}
}

# unpack data after getting from memcache
sub _unpack_cache_data {
	my $string = shift;
	my %table;
	for my $item( split(',', $string) ){
		$table{$item} = 1;
	}
	return keys %table;
}

# pack data before putting to memcache
sub _pack_cache_data {
	my @entities = @_;
	my %table;
	for my $item (@entities){
		$table{$item} = 1;
	};
	return join(',', keys(%table));
}

start;
