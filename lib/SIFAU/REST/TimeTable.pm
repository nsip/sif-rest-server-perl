package SIFAU::REST::TimeTables;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use SIFAU::REST::Plugin;

our $VERSION = '0.1';
prefix '/TimeTables';

get '/' => sub {
	autoGetCollection('TimeTables', 'TimeTable');
};

get '/:id' => sub {
	autoGet('TimeTable', 'TimeTable');
};

# CREATE Multiple
post '/' => sub {
	die "Not implemented";
};

# CREATE Single
post '/TimeTable' => sub {
	autoCreate('TimeTable', 'TimeTable');
};

# Update set
put '/' => sub {
	die "Not implemented";
};

# Update one
put '/:id' => sub {
	autoUpdate('TimeTable', 'TimeTable', params->{id});
};

# Delete Set
del '/' => sub {
	die "Not implemented";
};

# Delete Single
del '/:id' => sub {
	autoDelete('TimeTable', 'TimeTable', params->{id});
};

true;
