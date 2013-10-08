package SIFAU::REST::TimeTables;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use SIFAU::REST::Plugin;
use SIF::XML::Parse;
use Data::Dumper;
use XML::Simple;

our $VERSION = '0.1';
prefix '/TimeTables';

sub xml2data {
	my ($xml) = @_;
	my $raw = XMLin($xml, 
		ForceArray => [qw/TimeTableDay TimeTablePeriod/],
		ForceContent => 1,
		KeepRoot => 1,
	);
	SIF::XML::Parse::normalise($raw);
	return $raw;
}

get '/' => sub {
	my $sth = database->prepare(q{SELECT RefId FROM TimeTable});
	$sth->execute();
	my @data;
	while (my $r = $sth->fetchrow_hashref) {
		push @data, entry($r->{RefId});
	}
	return returnXML({
		status => 201,
		template => 'TimeTables',
		data => \@data,
	});
};

get '/:id' => sub {
	my $sth_find = database->prepare("SELECT * FROM TimeTable WHERE RefId = ?");
	$sth_find->execute(params->{id});
	my $old_data = $sth_find->fetchrow_hashref();
	if (!$old_data || ($old_data->{RefId} ne params->{id})) {
		return status_not_found("doesn't exists");
	}
	return returnXML({
		status => 201,
		template => 'TimeTable',
		entry => entry(params->{id}),
		data => [],
	});
};

sub entry {
	my ($id) = @_;

	my $sth = database->prepare(q{SELECT * FROM TimeTable WHERE RefId = ?});
	$sth->execute($id);
	my $data = $sth->fetchrow_hashref();
	$data->{TimeTableDay} = [];

	# Days
	$sth = database->prepare(q{
		SELECT
			*
		FROM
			TimeTable_Day
		WHERE
			TimeTable_RefId = ?
	});
	$sth->execute($id);

	# Periods
	my $sthperiod = database->prepare(q{
		SELECT
			*
		FROM
			TimeTable_Period
		WHERE
			TimeTable_RefId = ?
			AND DayId = ?
	});

	while ( my $r  = $sth->fetchrow_hashref()) {
		my $day = {
			DayId => $r->{DayId},
			DayTitle => $r->{DayTitle},
			Period => [],
		};
		$sthperiod->execute($id, $r->{DayId});
		while ( my $p  = $sthperiod->fetchrow_hashref()) {
			push @{$day->{Period}}, {
				PeriodId => $p->{PeriodId},
				PeriodTitle => $p->{PeriodTitle},
			};
		}
		push @{$data->{TimeTableDay}}, $day;
	}

	return $data;
}

# CREATE Multiple
post '/' => sub {
	die "Not implemented";
};

# CREATE Single
post '/TimeTable' => sub {
	my $data = xml2data(request->body);
	info(Dumper($data));

	my $refid = createRefId();
	$refid =~ s/\-//g;

	if (eval { $data->{TimeTable}{RefId} }) {
		$refid = $data->{TimeTable}{RefId};
	}

	my @bind = ();
	push @bind, $refid;
	push @bind, eval { $data->{TimeTable}{SchoolYear}{content} } // "";
	push @bind, eval { $data->{TimeTable}{LocalId}{content} } // "";
	push @bind, eval { $data->{TimeTable}{Title}{content} } // "";
	push @bind, eval { $data->{TimeTable}{SchoolInfoRefId}{content} } // "";
	push @bind, eval { $data->{TimeTable}{DaysPerCycle}{content} } // "";
	push @bind, eval { $data->{TimeTable}{PeriodsPerCycle}{content} } // "";
	
	info(join(",", @bind));
	my $sth = database->prepare(q{
		INSERT INTO TimeTable
			(RefId, SchoolYear, LocalId, Title, SchoolInfo_RefId, DaysPerCycle, PeriodsPerCycle)
		VALUES
			(?, ?, ?, ?, ?, ?, ?)
	});
	$sth->execute( @bind );

	my $sth_day = database->prepare(q{
		INSERT INTO TimeTable_Day
			(TimeTable_RefId, DayId, DayTitle)
		VALUES
			(?, ?, ?)
	});
	my $sth_period = database->prepare(q{
		INSERT INTO TimeTable_Period
			(TimeTable_RefId, DayId, PeriodId, PeriodTitle)
		VALUES
			(?, ?, ?, ?)
	});

	foreach my $d ( eval { @{$data->{TimeTable}{TimeTableDayList}{TimeTableDay}} } ) {
		$sth_day->execute($refid, $d->{DayId}{content}, $d->{DayTitle}{content});
		for my $p ( eval { @{$d->{TimeTablePeriodList}{TimeTablePeriod}} } ) {
			$sth_period->execute(
				$refid, $d->{DayId}{content},
				$p->{PeriodId}{content}, $p->{PeriodTitle}{content},
			);
		}
	}

	# TODO addQueue
	#addQueue({
	#	name => 'StudentPersonals',
	#	action => 'CREATE',
	#	xml => '<example>end</example>',
	#});
	
	database->commit();

	return forward '/TimeTables/' . $refid, { id => $refid }, {method => 'GET'};
};

# Update set
put '/' => sub {
	die "Not implemented";
};

# Update one
put '/:id' => sub {
	my $sth_find = database->prepare("SELECT * FROM TimeTable WHERE RefId = ?");
	$sth_find->execute(params->{id});
	my $old_data = $sth_find->fetchrow_hashref();
	if (!$old_data || ($old_data->{RefId} ne params->{id})) {
		return status_not_found("doesn't exists");
	}

	my $data = xml2data(request->body);
	info(Dumper($data));

	my $set = {};

	if (eval { $data->{TimeTable}{ShortName}{content} }) {
		$set->{"ShortName"} = $data->{TimeTable}{ShortName}{content};
	}
	if (eval { $data->{TimeTable}{LongName}{content} }) {
		$set->{"LongName"} = $data->{TimeTable}{LongName}{content};
	}
	if (eval { $data->{TimeTable}{LocalId}{content} }) {
		$set->{"LocalId"} = $data->{TimeTable}{LocalId}{content};
	}
	if (eval { $data->{TimeTable}{SchoolYear}{content} }) {
		$set->{"SchoolYear"} = $data->{TimeTable}{SchoolYear}{content};
	}
	if (eval { $data->{TimeTable}{SchoolInfoRefId}{content} }) {
		$set->{"SchoolInfo_RefId"} = $data->{TimeTable}{SchoolInfoRefId}{content};
	}

	# XXX Replace groups
	
	my $sth = database->prepare(q{
		UPDATE TimeTable
			SET } . join(", ", (map { "$_ = ?" } sort keys %{$set})) . q{
		WHERE
			RefId = ?
	});
	$sth->execute( (map { $set->{$_} } sort keys %{$set}), params->{id});

	if (eval { $data->{TimeTable}{TimeTableDayList} }) {
		database->do(q{DELETE FROM TimeTable_Period WHERE TeachingGroup_RefId = ?}, undef, params->{id});
		database->do(q{DELETE FROM TimeTable_Day WHERE TeachingGroup_RefId = ?}, undef, params->{id});

		my $sth_day = database->prepare(q{
			INSERT INTO TimeTable_Day
				(TimeTable_RefId, DayId, DayTitle)
			VALUES
				(?, ?, ?)
		});
		my $sth_period = database->prepare(q{
			INSERT INTO TimeTable_Period
				(TimeTable_RefId, DayId, PeriodId, PeriodTitle)
			VALUES
				(?, ?, ?, ?)
		});

		foreach my $d ( eval { @{$data->{TimeTable}{TimeTableDayList}{TimeTableDay}} } ) {
			$sth_day->execute(params->{id}, $d->{DayId}{content});
			for my $p ( eval { @{$d->{TimeTablePeriodList}{TimeTablePeriod}} } ) {
				$sth_period->execute(
					params->{id}, $d->{DayId}{content},
					$p->{PeriodId}{content}, $p->{PeriodTitle}{content},
				);
			}
		}
	}

	# TODO addQueue
	#addQueue({
	#	name => 'StudentPersonals',
	#	action => 'CREATE',
	#	xml => '<example>end</example>',
	#});
	
	database->commit();

	return forward '/TimeTables/' . params->{id}, { id => params->{id} }, {method => 'GET'};
};

# Delete Set
del '/' => sub {
	die "Not implemented";
};

# Delete Single
del '/:id' => sub {
	my $sth_find = database->prepare("SELECT * FROM TimeTable WHERE RefId = ?");
	$sth_find->execute(params->{id});
	my $old_data = $sth_find->fetchrow_hashref();
	if (!$old_data || ($old_data->{RefId} ne params->{id})) {
		return status_not_found("doesn't exists");
	}

	database->do(q{DELETE FROM TimeTable_Period WHERE TimeTable_RefId = ?}, undef, params->{id});
	database->do(q{DELETE FROM TimeTable_Day WHERE TimeTable_RefId = ?}, undef, params->{id});
	database->do(q{DELETE FROM TimeTable WHERE RefId = ?}, undef, params->{id});

	status_ok({success => true, comment => 'deleted'});
};

true;
