package SIFAU::REST::SchoolInfos;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use SIFAU::REST::Plugin;

our $VERSION = '0.1';
prefix '/SchoolInfos';

get '/' => sub {
	autoGetCollection('SchoolInfos', 'SchoolInfo');
};

get '/:id' => sub {
	autoGet('SchoolInfo', 'SchoolInfo');
};

# CREATE Multiple
post '/' => sub {
	die "Not implemented";
};

# CREATE Single
post '/SchoolInfo' => sub {
	autoCreate('SchoolInfo', 'SchoolInfo');
};

# Update set
put '/' => sub {
	die "Not implemented";
};

# Update one
put '/:id' => sub {
	autoUpdate('SchoolInfo', 'SchoolInfo', params->{id});
};

# Delete Set
del '/' => sub {
	die "Not implemented";
};

# Delete Single
del '/:id' => sub {
	autoDelete('SchoolInfo', 'SchoolInfo', params->{id});
};

true;
