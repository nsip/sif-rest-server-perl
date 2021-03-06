package SIFAU::REST::Plugin;
use Dancer ':syntax';
use Dancer::Plugin;
use Dancer::Plugin::Database;
use Dancer::Plugin::REST;
use Params::Check qw[check allow last_error];
use Data::GUID;
use SIF::XML::Parse;

=head1 NAME

TODO

=cut

# TODO - Support filters
register autoGetCollection => sub {
	my ($self, $template, $table, $sql) = plugin_args(@_);
	return getSQLCollection({
		sql => $sql // qq{
			SELECT *
			FROM $table
			ORDER BY RefId
		},
		template => $template,
	});
};

register autoGet => sub {
	my ($self, $template, $table, $sql) = plugin_args(@_);
	return getSQL({
		sql => $sql // qq{
			SELECT *
			FROM $table
			WHERE RefId = ?
		},
		bind => [ params->{id} ],
		template => $template,
	});
};

# TODO - auto support multiple !
register autoCreate => sub {
	my ($self, $template, $table) = plugin_args(@_);

	my $raw = eval{ SIF::XML::Parse->parse(request->body) };
	if ($@) {
		die "Failed to parse input XML - $@\n";
	}
	if ($raw->{type} ne $template) {
		die "Input data type does not match expected - $template != $raw->{type}\n";
	}

	# XXX Check existing RefId
	if ($raw->{data}{RefId} && ($raw->{data}{RefId} ne "")) {
		# Check valid format
		# TODO: Consider Check not exists - currently will fail during insert DB checks
	}
	else {
		$raw->{data}{RefId} = createRefId();
		# NOTE: Strip "-" form GUID to support SIF 1.3 AU Spec.
		$raw->{data}{RefId} =~ s/\-//g;
	}

	debug (join (",", sort keys %{$raw->{data}}));
	my @data = (map { $raw->{data}{$_} } sort keys %{$raw->{data}});

	# XXX Rough example
	addQueue({
		name => 'StudentPersonals',
		action => 'CREATE',
		xml => '<example>end</example>',
	});
	
	my $sth = database->prepare(qq{
		INSERT INTO $table
			(} . join(',', sort keys %{$raw->{data}}) . qq{)
		VALUES 
			(} . join(',', map { '?' } keys %{$raw->{data}}) . qq{)
	});
	$sth->execute( @data );

	return forward '/' . $table . 's/' . $raw->{data}{RefId}, { id => $raw->{data}{RefId} }, {method => 'GET'};
};

# TODO - auto support multiple !
register autoUpdate => sub {
	my ($self, $template, $table, $id) = plugin_args(@_);

	my $raw = eval{ SIF::XML::Parse->parse(request->body) };
	if ($@) {
		die "Failed to parse input XML - $@\n";
	}
	if ($raw->{type} ne $template) {
		die "Input data type does not match expected - $template != $raw->{type}\n";
	}

	my @set = ();
	my @value = ();
	foreach my $key (keys %{$raw->{data}}) {
		next if ($key eq 'RefId');
		if ($raw->{data}{$key}) {
			push @set, "$key = ?";
			push @value, $raw->{data}{$key};
		}
	}

	$raw->{data}{RefId} = $id;

	# TODO Return value may be wrong... might need to do a separate updateSQL
	push @value, $id;

	info(qq{
		UPDATE $table
		SET } . join(",", @set) . qq{
		WHERE RefId = ?
	});
	info(join(',', @value));
	my $sth = database->prepare(qq{
		UPDATE $table
		SET } . join(",", @set) . qq{
		WHERE RefId = ?
	});
	$sth->execute( @value );
	return forward '/' . $table . 's/' . $id, { id => $id }, {method => 'GET'};
};

# TODO - auto support multiple !
register autoDelete => sub {
	my ($self, $template, $table, $id) = plugin_args(@_);
	return deleteSQL({
		check => qq{SELECT * FROM $table WHERE RefId = ?},
		delete => qq{DELETE FROM $table WHERE RefId = ?},
		id => $id,
	});
};

# Query, Return Collection via Template
register getSQLCollection => sub {
	my ($self, $opts) = plugin_args(@_);

	my $sth = database->prepare( $opts->{sql});
	$sth->execute(
		exists $opts->{bind} ? @{$opts->{bind}} : ()
	);

	return returnXML({
		template => $opts->{template},
		data => $sth->fetchall_arrayref({}),
	});
};

# Query, Return ONE via Template
register getSQL => sub {
	my ($self, $opts) = plugin_args(@_);

	my $sth = database->prepare( $opts->{sql});
	$sth->execute(
		exists $opts->{bind} ? @{$opts->{bind}} : ()
	);

	my $entry = $sth->fetchrow_hashref();
	if (! $entry) {
		return status_not_found("doesn't exists");
	}
	return returnXML({
		template => $opts->{template},
		entry => $entry,
	});
};

register returnXML => sub {
	my ($self, $opts) = plugin_args(@_);
	content_type 'application/xml';
	# headers 'X-Foo' => 'bar', X-Bar => 'foo';
	my $base = uri_for('') . '';
	$base =~ s|/$||g;

	status $opts->{status} // 200;
	template 'xml/' . $opts->{template}, { 
		BASE => $base,
		data => $opts->{data},
		entry => $opts->{entry},
	}, { layout => undef };
};

register deleteSQL => sub {
	my ($self, $opts) = plugin_args(@_);
	# Check exists
	my $sth_find = database->prepare($opts->{check});
	$sth_find->execute( $opts->{id} );
	my $old_data = $sth_find->fetchrow_hashref();
	if (!$old_data || ($old_data->{RefId} ne $opts->{id})) {
		return status_not_found("doesn't exists");
	}

	my $sth = database->prepare($opts->{delete});
	$sth->execute( $opts->{id} );

	status_ok({success => true, comment => 'deleted'});
};

register createSQL => sub {
	my ($self, $opts) = plugin_args(@_);
	use Data::Dumper;
	debug(Dumper($opts));
	my $sth = database->prepare($opts->{create});
	$sth->execute( @{$opts->{bind}} );
	return returnXML({
		status => 201,
		template => $opts->{template},
		# XXX data vs entry ?
		entry => $opts->{entry},
		data => $opts->{data},
	});
};

register createRefId => sub {
	my $guid = Data::GUID->new;
	return $guid->as_string;
};

# name=StudentPersonals, action=CREATE, xml=><...>
register addQueue => sub {
	my ($self, $opts) = plugin_args(@_);
	
	# TODO: Matching Zone and Context (future support)
	
	my $sth = database->prepare(q{
		SELECT 
			id
		FROM 
			subscription
		WHERE 
			serviceType = 'OBJECT'
			AND serviceName = ?
	});
	$sth->execute($opts->{name});

	my $create_sth = database->prepare(q{
		INSERT INTO queue_data
			(id, subscription_id, event_datetime, action, data)
			VALUES (?, ?, 'now', ?, ?)
	});
	while (my $sub = $sth->fetchrow_hashref) {
		my $refid = createRefId();
		$create_sth->execute(
			$refid, $sub->{id}, $opts->{action}, $opts->{xml}
		);
		debug ("New queu entry $refid for " . $sub->{id});
	}
	database->commit();
};

register_plugin;

true
