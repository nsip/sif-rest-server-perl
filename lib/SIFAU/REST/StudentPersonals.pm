package SIFAU::REST::StudentPersonals;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use SIFAU::REST::Plugin;

our $VERSION = '0.1';
prefix '/StudentPersonals';

get '/' => sub {
	autoGetCollection('StudentPersonals', 'StudentPersonal');
};

get '/:id' => sub {
	autoGet('StudentPersonal', 'StudentPersonal');
};

# CREATE Multiple
post '/' => sub {
	autoCreate('StudentPersonal', 'StudentPersonal');
};

# CREATE Single
post '/StudentPersonal' => sub {
	autoCreate('StudentPersonal', 'StudentPersonal');
};

# Update set
put '/' => sub {
	die "Not implemented";
};

# Update one
put '/:id' => sub {
	autoUpdate('StudentPersonal', 'StudentPersonal', params->{id});
};

# Delete Set
del '/' => sub {
	die "Not implemented";
};

# Delete Single
del '/:id' => sub {
	autoDelete('StudentPersonal', 'StudentPersonal', params->{id});
};

true;
