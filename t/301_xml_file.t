use Test::More tests => 1;
use strict;
use warnings;
use lib './lib';
use Data::Dumper;

use_ok 'SIFAU::XML::Parse';

# SINGLE STUDENT
my $out = SIFAU::XML::Parse->parse(shift);
print Dumper($out);

