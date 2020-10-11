#!/usr/bin/env perl
use Dancer2;
use Dancer2::Plugin::Database;
use Dancer2::Plugin::REST;
use Dancer2::Plugin::Cache::CHI;
use LWP::UserAgent;
use Syntax::Keyword::Try;


get '/' => sub {
	status_ok({ok => 1});
};
