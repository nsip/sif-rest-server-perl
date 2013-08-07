package SIFAU::REST::RoomInfos;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use SIFAU::REST::Plugin;

our $VERSION = '0.1';
prefix '/RoomInfos';

get '/' => sub {
	autoGetCollection('RoomInfos', 'RoomInfo');
};

get '/:id' => sub {
	autoGet('RoomInfo', 'RoomInfo');
};

# CREATE Multiple
post '/' => sub {
	die "Not implemented";
};

# CREATE Single
post '/RoomInfo' => sub {
	autoCreate('RoomInfo', 'RoomInfo');
};

# Update set
put '/' => sub {
	die "Not implemented";
};

# Update one
put '/:id' => sub {
	autoUpdate('RoomInfo', 'RoomInfo', params->{id});
};

# Delete Set
del '/' => sub {
	die "Not implemented";
};

# Delete Single
del '/:id' => sub {
	autoDelete('RoomInfo', 'RoomInfo', params->{id});
};

true;
