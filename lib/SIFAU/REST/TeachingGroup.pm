package SIFAU::REST::TeachingGroups;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use SIFAU::REST::Plugin;

our $VERSION = '0.1';
prefix '/TeachingGroups';

get '/' => sub {
	autoGetCollection('TeachingGroups', 'TeachingGroup');
};

get '/:id' => sub {
	autoGet('TeachingGroup', 'TeachingGroup');
};

# CREATE Multiple
post '/' => sub {
	die "Not implemented";
};

# CREATE Single
post '/TeachingGroup' => sub {
	autoCreate('TeachingGroup', 'TeachingGroup');
};

# Update set
put '/' => sub {
	die "Not implemented";
};

# Update one
put '/:id' => sub {
	autoUpdate('TeachingGroup', 'TeachingGroup', params->{id});
};

# Delete Set
del '/' => sub {
	die "Not implemented";
};

# Delete Single
del '/:id' => sub {
	autoDelete('TeachingGroup', 'TeachingGroup', params->{id});
};

true;
