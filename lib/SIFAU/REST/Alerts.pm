package SIFAU::REST::Alerts;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;

our $VERSION = '0.1';
prefix '/alerts';

get '/' => sub {
	send_error("Not implemented", 501);
};

true;
