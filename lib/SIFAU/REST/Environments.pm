package SIFAU::REST::Environments;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use Data::GUID;
use Digest::SHA qw(sha1_hex);
use SIFAU::REST::Plugin;

our $VERSION = '0.1';
prefix '/environments';

# TODO - allow valid Consumer Key to see their own sessions
#	Since this should show all environments you can see, why not just show your own
get '/' => sub {
	return {
		success => false,
	};
};

# NOTE consumerKey / token is not returned on get... security
get '/:id' => sub {
	returnXML({
		template => 'environment',
		entry => {
			RefId => params->{id},
		},
	});
};

post '/environment' => sub {
	my $key = sha1_hex(createRefId());
	my $id = createRefId;
	returnXML({
		template => 'environment',
		entry => {
			RefId => $id,
			# TODO rename session Token? as per XML
			consumerKey => $key,
		},
	});
};

del '/:id' => sub {
	return {
		success => false,
	};
};

true;
