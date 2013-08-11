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
	my ($self, $template, $table) = plugin_args(@_);
	return getSQLCollection({
		sql => qq{
			SELECT *
			FROM $table
			ORDER BY RefId
		},
		template => $template,
	});
};

register autoGet => sub {
	my ($self, $template, $table) = plugin_args(@_);
	return getSQL({
		sql => qq{
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

	$raw->{data}{RefId} = createRefId();
	# NOTE: Strip "-" form GUID to support SIF 1.3 AU Spec.
	$raw->{data}{RefId} =~ s/\-//g;

	debug (join (",", sort keys %{$raw->{data}}));
	my @data = (map { $raw->{data}{$_} } sort keys %{$raw->{data}});

	# TODO - can we just trust all fields match DB ? (ie trust SIFAU::XML?)
	return createSQL({
		create => qq{
			INSERT INTO $table
				(} . join(',', sort keys %{$raw->{data}}) . qq{)
			VALUES 
				(} . join(',', map { '?' } keys %{$raw->{data}}) . qq{)
		},
		bind => \@data,
		entry => $raw->{data},
		template => $template,
	});
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
		push @set, "$key = ?";
		push @value, $raw->{data}{$key};
	}

	$raw->{data}{RefId} = $id;

	# TODO Return value may be wrong... might need to do a separate updateSQL
	push @value, $id;
	return createSQL({
		create => qq{
			UPDATE $table
			SET } . join(",", @set) . qq{
			WHERE RefId = ?
		},
		bind => \@value,
		entry => $raw->{data},
		template => $template,
	});
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

register_plugin;

true
