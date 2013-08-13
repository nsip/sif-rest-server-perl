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

get '/:id/messages' => sub {

	# Get most recent message

	# XXX Headers
	# 	messageId - All important message id to delete
	header 'messageId' => $ret->{id};
	# 	messageType - EVENT or ERROR
	header 'messageType' => 'EVENT';
	# 	zoneId - Future
	# 	contextId - Future
	# 	serviceType - OBJECT
	header 'serviceType' => 'OBJECT';
	# 	serviceName - StudentPersonal
	header 'serviceName' => $ret->{serviceName};
	# 	eventAction - CREATE, UPDATE, DELETE - if messageType EVENT
	header 'eventAction' => $ret->{action};
	#	responseAction - CREATE, UPDATE, DELETE - if messageType RESPONSE
	#	messageDateTime - DAte of the event
	header 'messageDateTime' => $ret->{event_datetime};
	#	generatorId - not supported yet
	#	providerId - who created the event ? (where do we find providers)

	# Delete old object
	

	returnXML({
		# XXX
	});
};

true;
