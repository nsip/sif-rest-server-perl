package SIFAU::REST::Subscriptions;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use SIFAU::REST::Plugin;

our $VERSION = '0.1';
prefix '/subscriptions';

=head1 NOTES

	POST /queues/queue = 
		<subscription>
		  <zoneId></zoneId>
		  <contextId></contextId>
		  <serviceType></serviceType>
		  <serviceName></serviceName>
		  <queueId></queueId>
		</subscription>

=cut

get '/' => sub {
	returnXML({
		template => 'queues',
		data => [],
	});
};

get '/:id' => sub {
	returnXML({
		template => 'environment',
		entry => {
			RefId => params->{id},
		},
	});
};

del '/:id' => sub {
	# XXX Delete
};

true;
