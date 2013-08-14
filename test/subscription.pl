#!/usr/bin/perl
use lib '/Users/scottp/nsip/sif-rest-perl/lib';
use SIF::REST;

my $sifrest = SIF::REST->new({ endpoint => 'http://localhost:3000' });
$sifrest->setupRest();

my $q_xml = $sifrest->post(
	'queues', 'queue', 
	q{<queue type="IMMEDIATE_POLLING"><name>test</name></queue>}
);
print $q_xml;
