package SIFAU::REST::Zones;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;

our $VERSION = '0.1';
prefix '/zones';

get '/' => sub {
	content_type 'application/xml';
	template 'xml/Zones', {
		BASE => uri_for('') . '',
		ID => params->{id},
		data => [
			{
				description => 'TODO',
				property => {
					testone => 'Test One',
				},
			},
		],
	}, { layout => undef };
};

get '/:id' => sub {
	content_type 'application/xml';
	template 'xml/Zone', {
		BASE => uri_for('') . '',
		ID => params->{id},
		entry => {
			description => 'TODO',
			property => {
				testone => 'Test One',
			},
		},
	}, { layout => undef };
};

true;
