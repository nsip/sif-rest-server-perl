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

post '/queue' => sub {
	# XXX XML in request->body to get name

	my $sth = database->prepare(q{
		INSERT INTO queue
			(id, name)
		VALUES (?, ?)
	});
	my $refid = createRefId;
	$sth->execute($refid, 'test');
	returnXML({
		template => 'queue',
		entry => {
			RefId => $refid,
			name => 'test',
		},
	});
};

get '/' => sub {
	# XXX TODO
	return {
		success => false,
	};
};

# NOTE consumerKey / token is not returned on get... security
get '/:id' => sub {
	# XXX TODO
	returnXML({
		template => 'environment',
		entry => {
			RefId => params->{id},
		},
	});
};

get '/:id/messages;deleteMessageId=:delId' => sub {
	# TODO - Check subscripts queue enviornment belongs to this user !!!
	# TODO - Check this ID is the first object in the table
	my $sth = database->prepare(q{
		DELETE FROM
			queue_data
		WHERE
			queue_data.id = ?
	});
	$sth->execute(params->{id});
	database->execute();

	# TODO - Check for errors

	# Rediret 
	forward '/queues/' . params->{id} . '/messages';
};

get '/:id/messages' => sub {
	# Get most recent message
	# TODO - Check subscripts queue enviornment belongs to this user !!!
	# TODO - ISO date format
	my $sth = database->prepare(q{
		SELECT
			queue_data.id as id, queue.id as queue_id,
			queue_data.event_datetime, queue_data.action, queue_data.data,
			subscription.serviceName as serviceName
		FROM
			queue_data, subscription, queue
		WHERE
			queue_data.subscription_id = subscription.id
			AND subscription.queue_id = queue.id
			AND queue.id = ?
		ORDER BY
			id
		LIMIT 1
	});
	$sth->execute(params->{id});
	my $ret = $sth->fetchrow_hashref;

	# TODO 204 - no data

	# Headers
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

	content_type 'application/xml';
	status 200;
	return $ret->{data};
};

true;
