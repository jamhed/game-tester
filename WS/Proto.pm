package WS::Proto;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(on_msg on_bcast snmsg msg);
use strict;
use JSON;

# private
my $_seq = 1;
my $client;

# package registers with standard handlers
our $_cb = {};

our $_bt = {};

# package interface
sub on_msg {
	my ($msg, $callback) = @_;
	$_cb->{$msg} = $callback;
}

sub on_bcast {
	my ($msg, $callback) = @_;
	$_bt->{$msg} = $callback;
}


sub make_handler {
	return sub {
		my ($ws_status, $reply) = @_;
		if ($ws_status eq 'err') {
			warn "ws protocol error: $reply";
			return;
		}
		my ($status, $cmd, @re) = my @rpl = @{from_json($reply)};
		if ($status eq 'ok') {
			if($cmd eq 'nmsg') {
				my ($reply_seq, @response) = @re;
				if (defined $_cb->{$reply_seq}) {
					$_cb->{$reply_seq}->(@response);
				} else {
					warn "undefined seq callback: $reply_seq";
				}
				delete $_cb->{$reply_seq};
			} elsif ($cmd eq 'msg') {
				my ($msg, @response) = @re;
				if (defined $_cb->{$msg}) {
					$_cb->{$msg}->(@response);
				} else {
					warn "undefined msg callback: $msg";
				}
				delete $_cb->{$msg};
			} elsif ($cmd eq 'bcast') {
				my ($msg, @response) = @re;
				if (defined $_bt->{$msg}) {
					$_bt->{$msg}->(@response);
				} else {
					warn "unhandled broadcast: $msg";
				}
			} else {
				warn "unhandled reply: @rpl";
			}
		} else {
			warn "bad reply: @rpl";
		}
	}
}

sub snmsg {
	my ($msg, $callback) = @_;
	my $seq = $_seq++;
	$_cb->{$seq} = $callback;
	my @cmd = ("snmsg", 0+$seq, @$msg);
	WS::Connect::write(to_json(\@cmd));
}

sub msg {
	my ($msg, $callback) = @_;
	$_cb->{$msg->[0]} = $callback;
	my @cmd = ("msg", @$msg);
	WS::Connect::write(to_json(\@cmd));
}

1;
