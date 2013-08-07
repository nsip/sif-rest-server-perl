package SIFAU::REST::StaffPersonals;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use SIFAU::REST::Plugin;

our $VERSION = '0.1';
prefix '/StaffPersonals';

get '/' => sub {
	autoGetCollection('StaffPersonals', 'StaffPersonal');
};

get '/:id' => sub {
	autoGet('StaffPersonal', 'StaffPersonal');
};

# CREATE Multiple
post '/' => sub {
	die "Not implemented";
};

# CREATE Single
post '/StaffPersonal' => sub {
	autoCreate('StaffPersonal', 'StaffPersonal');
};

# Update set
put '/' => sub {
	die "Not implemented";
};

# Update one
put '/:id' => sub {
	autoUpdate('StaffPersonal', 'StaffPersonal', params->{id});
};

# Delete Set
del '/' => sub {
	die "Not implemented";
};

# Delete Single
del '/:id' => sub {
	autoDelete('StaffPersonal', 'StaffPersonal', params->{id});
};

true;
