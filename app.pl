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

# getting list of images and caching
get '/images' => sub {
	my $images;
	try {
		$images = _api_call( GET => '/images', params() );
		if( $images->{pictures} ){
			for my $image (@{$images->{pictures}}){
				my $image_details = _api_call( GET => '/images/'.$image->{id} );
				_cache_image_data($image_details);
			}
		}
	} catch {
		return status_error({error => $@});
	}
	status_ok({list=>$images});
};

# getting api token
sub _get_auth_token {
	my $api_key = shift;

	my $request = HTTP::Request->new(POST => 'http://interview.agileengine.com:80/auth');
	$request->content_type('application/json');
	$request->content(encode_json({apiKey => $api_key}));

	my $ua = LWP::UserAgent->new();
	my $response = $ua->request($request);

	if( $response->is_success ){
		my $result; 
		try {
			$result = decode_json($response->content);
		} catch {
			die 'Error while parsing response '.$@;
		}

		if($result->{auth}){
			return $result->{token};
		} else {
			die "Result 'auth' is not true";
		}
	} else {
		die 'Error while retrieving token '.$response->status_line;
	}
}

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
