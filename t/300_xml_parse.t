use Test::More tests => 1;
use strict;
use warnings;
use lib './lib';
use Data::Dumper;

use_ok 'SIFAU::XML::Parse';

# SINGLE STUDENT
my $out = SIFAU::XML::Parse->parse(
q{<student xmlns:sif="http://www.sifassociation.org/datamodel/global/3.0">
    <localId>LocalID</localId>
    <name nameRole="">
      <nameOfRecord>
        <familyName>Family Name</familyName>
        <givenName>Given Name</givenName>
      </nameOfRecord>
    </name>
</student>
});
print Dumper($out);

# MULTIPLE STUDENTS, with a SINGLE STUDENT
print Dumper(SIFAU::XML::Parse->parse(
q{<sif:students xmlns:sif="http://www.sifassociation.org/datamodel/global/3.0">
  <student>
    <localId>LocalID</localId>
    <name nameRole="">
      <nameOfRecord>
        <familyName>Family Name</familyName>
        <givenName>Given Name</givenName>
      </nameOfRecord>
    </name>
  </student>
</sif:students>
}));

# MULTIPLE STUDENTS, with a MULTIPLE STUDENTS
print Dumper(SIFAU::XML::Parse->parse(
q{<sif:students xmlns:sif="http://www.sifassociation.org/datamodel/global/3.0">
  <student>
    <localId>LocalID 1</localId>
    <name nameRole="">
      <nameOfRecord>
        <familyName>Family Name 1</familyName>
        <givenName>Given Name 1</givenName>
      </nameOfRecord>
    </name>
  </student>
  <student>
    <localId>LocalID 2</localId>
    <name nameRole="">
      <nameOfRecord>
        <familyName>Family Name 2</familyName>
        <givenName>Given Name 2</givenName>
      </nameOfRecord>
    </name>
  </student>
</sif:students>
}));

# TODO - With and Without Namespace, including named and unnamed

