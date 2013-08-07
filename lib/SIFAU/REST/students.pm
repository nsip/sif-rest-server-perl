package SIFAU::REST::students;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use SIFAU::REST::Plugin;

our $VERSION = '0.1';
prefix '/students';

# NOTE: Sample - matches US SIF 3.0

get '/' => sub {
	autoGetCollection('students', 'StudentPersonal');
};

get '/:id' => sub {
	autoGet('student', 'StudentPersonal');
};

# CREATE Multiple
post '/' => sub {
	die "Not implemented";
};

# CREATE Single
post '/student' => sub {
	autoCreate('student', 'StudentPersonal');
};

# Update set
put '/' => sub {
	die "Not implemented";
};

# Update one
put '/:id' => sub {
	autoUpdate('student', 'StudentPersonal', params->{id});
};

# Delete Set
del '/' => sub {
	die "Not implemented";
};

# Delete Single
del '/:id' => sub {
	autoDelete('student', 'StudentPersonal', params->{id});
};

true;
