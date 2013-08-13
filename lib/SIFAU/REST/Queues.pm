package SIFAU::REST::Queues;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use SIFAU::REST::Plugin;

our $VERSION = '0.1';
prefix '/queues';

=head1 NOTES

	POST /queues/queue = 
			<queue type="IMMEDIATE_POLLING">
			  <name></name>
			</queue>
			return queue.tt

	GET /queues/:id =
			queue.tt

	GET /queues/:id/messages
		Return top message
		;deleteMessageId=2

=cut

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
