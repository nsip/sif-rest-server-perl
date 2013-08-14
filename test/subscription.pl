#!/usr/bin/perl
use lib '/Users/scottp/nsip/sif-rest-perl/lib';
use SIF::REST;
use XML::Simple;

my $sifrest = SIF::REST->new({ endpoint => 'http://localhost:3000' });
$sifrest->setupRest();

# Create QUEUE
my $q_xml = $sifrest->post(
	'queues', 'queue', 
	q{<queue type="IMMEDIATE_POLLING"><name>test</name></queue>}
);
print $q_xml;
my $q_data = XMLin($q_xml);

# Create SUBSCRIPTION
my $s_xml = $sifrest->post(
	'subscriptions', 'subscription', 
	q{<subscription>
		  <serviceType>OBJECT</serviceType>
		  <serviceName>StudentPersonals</serviceName>
		  <queueId>} . $q_data->{id} . q{</queueId>
		</subscription>
	},
);
print $s_xml;

# Check QUEUE
while (1) {
	print "get\n";
	print $sifrest->get('queues', $q_data->{id} . '/messages');
	<STDIN>;
}


# Create STUDENT


# Check QUEUE

