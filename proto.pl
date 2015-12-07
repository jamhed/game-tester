#!/usr/bin/env perl
use open IO  => ':locale';
use WS::Connect;
use WS::Proto qw(on_msg on_bcast snmsg msg);
use Test::Spec;

our $host = '127.0.0.1';
our $port = '9080';
our $init_message = ["msg", "user/new"];
our $ws_url = "ws://$host:$port/main/ws/";

my ($sid, $uid, $user);

# run tests
on_msg "user/new", sub {
	($sid, $user) = @_;
	$uid = $user->{id};
	warn "sid:$sid uid:$uid";
	runtests;
};

describe "front page" => sub {
	it 'has one online user' => sub {
		my $text = shift->description;
		snmsg([$sid+0, "user/online/count"], sub {
			my ($count) = @_;
			is($count, 1, $text);
		});
	};

	it 'has online user with same user id' => sub {
		my $text = shift->description;
		snmsg([$sid+0, "user/online"], sub {
			my ($user) = @_;
			is($user->{id}, $uid, $text);
		});
	};

	it 'handled user/logout correctly' => sub {
		my $text = shift->description;
		msg(["user/logout"], sub {
			ok(1, $text); # we were called in success only
		});
	};
};

our $handler = WS::Proto::make_handler();
WS::Connect::connect($host, $port, $ws_url, $init_message, $handler);
