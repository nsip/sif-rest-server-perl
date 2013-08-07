package SIFAU::REST::TimeTableSubjects;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use SIFAU::REST::Plugin;

our $VERSION = '0.1';
prefix '/TimeTableSubjects';

get '/' => sub {
	autoGetCollection('TimeTableSubjects', 'TimeTableSubject');
};

get '/:id' => sub {
	autoGet('TimeTableSubject', 'TimeTableSubject');
};

# CREATE Multiple
post '/' => sub {
	die "Not implemented";
};

# CREATE Single
post '/TimeTableSubject' => sub {
	autoCreate('TimeTableSubject', 'TimeTableSubject');
};

# Update set
put '/' => sub {
	die "Not implemented";
};

# Update one
put '/:id' => sub {
	autoUpdate('TimeTableSubject', 'TimeTableSubject', params->{id});
};

# Delete Set
del '/' => sub {
	die "Not implemented";
};

# Delete Single
del '/:id' => sub {
	autoDelete('TimeTableSubject', 'TimeTableSubject', params->{id});
};

true;
