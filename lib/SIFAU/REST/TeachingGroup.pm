package SIFAU::REST::TeachingGroups;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use SIFAU::REST::Plugin;
use SIF::XML::Parse;
use Data::Dumper;
use XML::Simple;

our $VERSION = '0.1';
prefix '/TeachingGroups';

sub xml2data {
	my ($xml) = @_;
	my $raw = XMLin($xml, 
		ForceArray => [qw/TeachingGroupTeacher TeachingGroupStudent/],
		ForceContent => 1,
		KeepRoot => 1,
	);
	SIF::XML::Parse::normalise($raw);
	return $raw;
}

get '/' => sub {
	my $sth = database->prepare(q{SELECT RefId FROM TeachingGroup});
	$sth->execute();
	my @data;
	while (my $r = $sth->fetchrow_hashref) {
		push @data, entry($r->{RefId});
	}
	return returnXML({
		status => 201,
		template => 'TeachingGroups',
		data => \@data,
	});
};

get '/:id' => sub {
	my $sth_find = database->prepare("SELECT * FROM TeachingGroup WHERE RefId = ?");
	$sth_find->execute(params->{id});
	my $old_data = $sth_find->fetchrow_hashref();
	if (!$old_data || ($old_data->{RefId} ne params->{id})) {
		return status_not_found("doesn't exists");
	}
	return returnXML({
		status => 201,
		template => 'TeachingGroup',
		entry => entry(params->{id}),
		data => [],
	});
};

sub entry {
	my ($id) = @_;

	my $sth = database->prepare(q{SELECT * FROM TeachingGroup WHERE RefId = ?});
	$sth->execute($id);
	my $data = $sth->fetchrow_hashref();
	$data->{students} = [];
	$data->{teachers} = [];

	# Students
	$sth = database->prepare(q{
		SELECT
			StudentPersonal.RefId, 
			StudentPersonal.GivenName, StudentPersonal.FamilyName
		FROM
			StudentPersonal, TeachingGroup_Student 
		WHERE
			StudentPersonal.RefId = TeachingGroup_Student.StudentPersonal_RefId
			AND TeachingGroup_Student.TeachingGroup_RefId = ?
	});
	$sth->execute($id);
	while ( my $r  = $sth->fetchrow_hashref()) {
		push @{$data->{students}}, { %$r };
	}

	# Teachers
	$sth = database->prepare(q{
		SELECT
			StaffPersonal.RefId, 
			StaffPersonal.GivenName, StaffPersonal.FamilyName
		FROM
			StaffPersonal, TeachingGroup_Teacher 
		WHERE
			StaffPersonal.RefId = TeachingGroup_Teacher.StaffPersonal_RefId
			AND TeachingGroup_Teacher.TeachingGroup_RefId = ?
	});
	$sth->execute($id);
	while ( my $r  = $sth->fetchrow_hashref()) {
		push @{$data->{teachers}}, { %$r };
	}

	return $data;
}

# CREATE Multiple
post '/' => sub {
	die "Not implemented";
};

# CREATE Single
post '/TeachingGroup' => sub {
	my $data = xml2data(request->body);
	info(Dumper($data));

	# Fields: ShortName, LongName, SchoolInfoRefId, LocalId
	# Groups: 
	# 	TeacherList/TeachingGroupTeacher -> StaffPersonalRefId/content
	# 	StudentList/TeachingGroupStudent -> StudentPersonalRefId/content

	my $refid = createRefId();
	$refid =~ s/\-//g;

	if (eval { $data->{TeachingGroup}{RefId} }) {
		$refid = $data->{TeachingGroup}{RefId};
	}

	my @bind = ();
	push @bind, $refid;
	push @bind, eval { $data->{TeachingGroup}{ShortName}{content} } // "";
	push @bind, eval { $data->{TeachingGroup}{LongName}{content} } // "";
	push @bind, eval { $data->{TeachingGroup}{LocalId}{content} } // "";
	push @bind, eval { $data->{TeachingGroup}{SchoolYear}{content} } // "";
	push @bind, eval { $data->{TeachingGroup}{SchoolInfoRefId}{content} } // "";
	
	info(join(",", @bind));
	my $sth = database->prepare(q{
		INSERT INTO TeachingGroup
			(RefId, ShortName, LongName, LocalId, SchoolYear, SchoolInfo_RefId)
		VALUES
			(?, ?, ?, ?, ?, ?)
	});
	$sth->execute( @bind );

	my $sth_teacher = database->prepare(q{
		INSERT INTO TeachingGroup_Teacher
			(TeachingGroup_RefId, StaffPersonal_RefId)
		VALUES
			(?, ?)
	});
	foreach my $t ( eval { @{$data->{TeachingGroup}{TeacherList}{TeachingGroupTeacher}} } ) {
		$sth_teacher->execute($refid, $t->{StaffPersonalRefId}{content});
	}

	my $sth_student = database->prepare(q{
		INSERT INTO TeachingGroup_Student
			(TeachingGroup_RefId, StudentPersonal_RefId)
		VALUES
			(?, ?)
	});
	foreach my $t ( eval { @{$data->{TeachingGroup}{StudentList}{TeachingGroupStudent}} } ) {
		$sth_student->execute($refid, $t->{StudentPersonalRefId}{content});
	}

	# TODO addQueue
	#addQueue({
	#	name => 'StudentPersonals',
	#	action => 'CREATE',
	#	xml => '<example>end</example>',
	#});
	
	database->commit();

	return forward '/TeachingGroups/' . $refid, { id => $refid }, {method => 'GET'};
};

# Update set
put '/' => sub {
	die "Not implemented";
};

# Update one
put '/:id' => sub {
	my $sth_find = database->prepare("SELECT * FROM TeachingGroup WHERE RefId = ?");
	$sth_find->execute(params->{id});
	my $old_data = $sth_find->fetchrow_hashref();
	if (!$old_data || ($old_data->{RefId} ne params->{id})) {
		return status_not_found("doesn't exists");
	}

	my $data = xml2data(request->body);
	info(Dumper($data));

	# Fields: ShortName, LongName, SchoolInfoRefId, LocalId
	# Groups: 
	# 	TeacherList/TeachingGroupTeacher -> StaffPersonalRefId/content
	# 	StudentList/TeachingGroupStudent -> StudentPersonalRefId/content

	my $set = {};

	if (eval { $data->{TeachingGroup}{ShortName}{content} }) {
		$set->{"ShortName"} = $data->{TeachingGroup}{ShortName}{content};
	}
	if (eval { $data->{TeachingGroup}{LongName}{content} }) {
		$set->{"LongName"} = $data->{TeachingGroup}{LongName}{content};
	}
	if (eval { $data->{TeachingGroup}{LocalId}{content} }) {
		$set->{"LocalId"} = $data->{TeachingGroup}{LocalId}{content};
	}
	if (eval { $data->{TeachingGroup}{SchoolYear}{content} }) {
		$set->{"SchoolYear"} = $data->{TeachingGroup}{SchoolYear}{content};
	}
	if (eval { $data->{TeachingGroup}{SchoolInfoRefId}{content} }) {
		$set->{"SchoolInfo_RefId"} = $data->{TeachingGroup}{SchoolInfoRefId}{content};
	}

	# XXX Replace groups
	

	if ( scalar( keys %$set ) > 0 ) {
		debug(q{
			UPDATE TeachingGroup
				SET } . join(", ", (map { "$_ = ?" } sort keys %{$set})) . q{
			WHERE
				RefId = ?
		});
		debug(join(",", (map { $set->{$_} } sort keys %{$set}), params->{id}));

		my $sth = database->prepare(q{
			UPDATE TeachingGroup
				SET } . join(", ", (map { "$_ = ?" } sort keys %{$set})) . q{
			WHERE
				RefId = ?
		});
		$sth->execute( (map { $set->{$_} } sort keys %{$set}), params->{id});
	}
	else {
		debug("No data to update");
	}

	if (eval { $data->{TeachingGroup}{TeacherList} }) {
		database->do(q{DELETE FROM TeachingGroup_Teacher WHERE TeachingGroup_RefId = ?}, undef, params->{id});
		my $sth_teacher = database->prepare(q{
			INSERT INTO TeachingGroup_Teacher
				(TeachingGroup_RefId, StaffPersonal_RefId)
			VALUES
				(?, ?)
		});
		foreach my $t ( eval { @{$data->{TeachingGroup}{TeacherList}{TeachingGroupTeacher}} } ) {
			$sth_teacher->execute(params->{id}, $t->{StaffPersonalRefId}{content});
		}
	}

	if (eval { $data->{TeachingGroup}{StudentList} }) {
		database->do(q{DELETE FROM TeachingGroup_Student WHERE TeachingGroup_RefId = ?}, undef, params->{id});
		my $sth_student = database->prepare(q{
			INSERT INTO TeachingGroup_Student
				(TeachingGroup_RefId, StudentPersonal_RefId)
			VALUES
				(?, ?)
		});
		foreach my $t ( eval { @{$data->{TeachingGroup}{StudentList}{TeachingGroupStudent}} } ) {
			$sth_student->execute(params->{id}, $t->{StudentPersonalRefId}{content});
		}
	}

	# TODO addQueue
	#addQueue({
	#	name => 'StudentPersonals',
	#	action => 'CREATE',
	#	xml => '<example>end</example>',
	#});
	
	database->commit();

	return forward '/TeachingGroups/' . params->{id}, { id => params->{id} }, {method => 'GET'};
};

# Delete Set
del '/' => sub {
	die "Not implemented";
};

# Delete Single
del '/:id' => sub {
	my $sth_find = database->prepare("SELECT * FROM TeachingGroup WHERE RefId = ?");
	$sth_find->execute(params->{id});
	my $old_data = $sth_find->fetchrow_hashref();
	if (!$old_data || ($old_data->{RefId} ne params->{id})) {
		return status_not_found("doesn't exists");
	}

	database->do(q{DELETE FROM TeachingGroup_Teacher WHERE TeachingGroup_RefId = ?}, undef, params->{id});
	database->do(q{DELETE FROM TeachingGroup_Student WHERE TeachingGroup_RefId = ?}, undef, params->{id});
	database->do(q{DELETE FROM TeachingGroup WHERE RefId = ?}, undef, params->{id});

	status_ok({success => true, comment => 'deleted'});
};

true;
