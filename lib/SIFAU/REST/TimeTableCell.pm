package SIFAU::REST::TimeTableCells;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use SIFAU::REST::Plugin;

our $VERSION = '0.1';
prefix '/TimeTableCells';

get '/' => sub {
	autoGetCollection('TimeTableCells', 'TimeTableCell', q{
		SELECT 
			TimeTableCell.RefId, TimeTableCell.
		FROM
			TimeTableCell
	});
};

get '/:id' => sub {
	autoGet('TimeTableCell', 'TimeTableCell', q{
	});
};

# CREATE Multiple
post '/' => sub {
	die "Not implemented";
};

# CREATE Single
post '/TimeTableCell' => sub {
	autoCreate('TimeTableCell', 'TimeTableCell');
};

# Update set
put '/' => sub {
	die "Not implemented";
};

# Update one
put '/:id' => sub {
	autoUpdate('TimeTableCell', 'TimeTableCell', params->{id});
};

# Delete Set
del '/' => sub {
	die "Not implemented";
};

# Delete Single
del '/:id' => sub {
	autoDelete('TimeTableCell', 'TimeTableCell', params->{id});
};

true;
