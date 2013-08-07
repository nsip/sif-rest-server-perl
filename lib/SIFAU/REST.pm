package SIFAU::REST;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use MIME::Base64;

# Auth
use SIFAU::REST::Environments;

# Infrastructure
use SIFAU::REST::Zones;
use SIFAU::REST::Subscriptions;
use SIFAU::REST::Queues;

# SIF-US 3.0
use SIFAU::REST::students;

# SIF-AU 1.3
use SIFAU::REST::StudentPersonals;
use SIFAU::REST::SchoolInfos;
use SIFAU::REST::StaffPersonals;
use SIFAU::REST::RoomInfos;
use SIFAU::REST::TeachingGroup;
use SIFAU::REST::TimeTable;
use SIFAU::REST::TimeTableCell;
use SIFAU::REST::TimeTableSubject;

our $VERSION = '0.1';
prefix undef;
set serializer => 'mutable';

get '/' => sub {
    template 
		'index', 
		{
			objects => [],
			version => 1,
		},
		{
			layout => undef
		}
	;
};

# SECURITY
# AUTHENTICATION & SECURITY
hook 'before' => sub {
	var securityMethod => 'NONE';
	# return true if (config->{sif}{security} eq 'none');

	# XXX Debugging - ignore security
	return true;

	given (request->path_info) {
		when (m|^/$|) {
			return true;
		}

		when (m|/environments/environment|) {
			# BASIC AUTH !
			my ($u, $p) = getAuth();
			if ($u ne 'new') {
				debug("Invalid user = $u : ???");
				return badAuth();
			}
			if ($p ne 'guest') {
				debug("Invalid password = '$u' : '???'");
				return badAuth();
			}
			return true;
		}

		default {
			my ($u, $p) = getAuth();
			# XXX Check $u is a proper entry
			if ($u !~ /^[A-Za-z0-9]+[0-9]+/) {
				debug("Invalid user = $u : ???");
				return badAuth();
			}
			if ($p ne 'guest') {
				debug("Invalid password = $u : ???");
				return badAuth();
			}
			session lastAccess => time + 0;
			return true;
			# Environment !
		}
	};

	my $res = Dancer::Response->new(
		status => 403,
		content => {
			success => false,
			message => "not logged in",
		},
	);
	$res->content_type('application/json');
	return halt($res);
};

sub getAuth {
	my $auth = request->header('Authorization');
	if (defined $auth && $auth =~ /^Basic (.*)$/) {
		my $in = MIME::Base64::decode($1) || ":";
		$in =~ s/[\r\n]$//g;
		return split(/:/, $in, 2);
	}
	return ();
}

sub badAuth {
	my $res = Dancer::Response->new(
		status => 401,
		content => {
			success => false,
			message => "not logged in",
		},
	);
	# XXX XML return type needs to be completed
	# $res->content_type('application/json');
	return halt($res);
};

true;
