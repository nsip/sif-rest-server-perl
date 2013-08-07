use Test::More tests => 1;
use strict;
use warnings;
use lib './lib';
use Data::Dumper;
use Template;

use_ok 'SIFAU::XML::Parse';

my $template = Template->new({
	INCLUDE_PATH => 'views',
});

my $xml = "";
$template->process(shift, {
	entry => {
		LocalId => 'ABC123',
		FamilyName => 'Smith',
		GivenName => 'John',
	},
}, \$xml) || die $template->error();

# SINGLE STUDENT
my $out = SIFAU::XML::Parse->parse($xml);
print Dumper($out);

