package SIFAU::REST::Subscriptions;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use SIFAU::REST::Plugin;
use XML::Simple;

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

post '/subscription' => sub {
	my $data = XMLin(request->body);

	my $sth = database->prepare(q{
		INSERT INTO subscription
			(id, queue_id, serviceType, serviceName)
		VALUES (?, ?, 'OBJECT', ?)
	});
	my $refid = createRefId;
	$sth->execute($refid, $data->{queueId}, $data->{serviceName});
	returnXML({
		template => 'subscription',
		entry => {
			RefId => $refid,
			queueId => $data->{queueId},
			serviceName => $data->{serviceName},
		},
	});
};

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
