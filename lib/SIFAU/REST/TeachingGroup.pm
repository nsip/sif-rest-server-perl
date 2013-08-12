package SIFAU::REST::TeachingGroups;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use SIFAU::REST::Plugin;

our $VERSION = '0.1';
prefix '/TeachingGroups';

get '/' => sub {
	#autoGetCollection('TeachingGroups', 'TeachingGroup');
	content_type 'application/xml';
	return "<TeachingGroups>" . fake() . "</TeachingGroups>";
};

get '/:id' => sub {
	#autoGet('TeachingGroup', 'TeachingGroup');
	content_type 'application/xml';
	return fake();
};

sub fake {
	return q{<TeachingGroup RefId="fake01">
  <SchoolYear>2007</SchoolYear>
  <SchoolInfoRefId>DC56C532026B11E3A5325DE06940ABA3</SchoolInfoRefId>
  <LocalId>X1</LocalId>
  <ShortName>Shortish</ShortName>
  <LongName>Longish</LongName>

  <StudentList>
    <TeachingGroupStudent>
      <StudentPersonalRefId>164da5d9bcbf4cf8a058ba0b0efde9ba</StudentPersonalRefId>
      <Name Type="LGL">
        <FamilyName>DAVEY</FamilyName>
        <GivenName>Tim</GivenName>
      </Name>
    </TeachingGroupStudent>
    <TeachingGroupStudent>
      <StudentPersonalRefId>DC7AA9C0026B11E3A5325DE06940ABA3</StudentPersonalRefId>
      <Name Type="LGL">
        <FamilyName>SAXTON</FamilyName>
        <GivenName>Sam</GivenName>
      </Name>
    </TeachingGroupStudent>
  </StudentList>

  <TeacherList>
    <TeachingGroupTeacher>
      <StaffPersonalRefId>E9E07EDC026B11E3A5325DE06940ABA3</StaffPersonalRefId>
      <Name Type="LGL">
        <FamilyName>CORR</FamilyName>
        <GivenName>Anne</GivenName>
      </Name>
      <Association>Class Teacher</Association>
    </TeachingGroupTeacher>
  </TeacherList>

</TeachingGroup>};
}		

# CREATE Multiple
post '/' => sub {
	die "Not implemented";
};

# CREATE Single
post '/TeachingGroup' => sub {
	autoCreate('TeachingGroup', 'TeachingGroup');
};

# Update set
put '/' => sub {
	die "Not implemented";
};

# Update one
put '/:id' => sub {
	autoUpdate('TeachingGroup', 'TeachingGroup', params->{id});
};

# Delete Set
del '/' => sub {
	die "Not implemented";
};

# Delete Single
del '/:id' => sub {
	autoDelete('TeachingGroup', 'TeachingGroup', params->{id});
};

true;
