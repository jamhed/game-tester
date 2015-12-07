package WS::Spec;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(sid uid user run);
use WS::Connect;
use WS::Proto qw(on_msg on_bcast snmsg msg);
use Test::Spec;
use strict;

# config params
our $host = '127.0.0.1';
our $port = '9080';
our $init_message = ["msg", "user/new"];
our $ws_url = "ws://$host:$port/main/ws/";

# package globals
our ($sid, $uid, $user);

#interface
sub sid { 0+$sid }
sub uid { 0+$uid }
sub user { $user }

sub run {
    my $class = caller;
    on_msg "user/new", sub {
    	($sid, $user) = @_;
    	$uid = $user->{id};
    	warn "sid:$sid uid:$uid";
    	$class->runtests_no_plan;
    };

    on_bcast "user/logout", sub {
        $class->done_testing;
        exit;
    };

    my $handler = WS::Proto::make_handler();
    WS::Connect::connect($host, $port, $ws_url, $init_message, $handler);
}

1;
