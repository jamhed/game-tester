package WS::Connect;
use strict;
use EV;
use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle;
use Protocol::WebSocket::Client;
use JSON;

$| = 1;

our $client;

sub write {
	my ($msg) = @_;
	$client->write($msg);
}

sub connect {
	my ($host, $port, $ws_url, $init_message, $handler) = @_;

	tcp_connect $host, $port, sub {
		my ($fh) = @_ or return $handler->('err', $!);

		$client = Protocol::WebSocket::Client->new(url => $ws_url);

		my $ws_handle = AnyEvent::Handle->new(
			fh => $fh,
			on_eof => sub { $handler->('err', 'eof') },
			on_error => sub { $handler->('err', $!) },
			on_read => sub {
				my ($handle) = @_;
				my $buf = delete $handle->{rbuf};
				$client->read($buf);
			}
		);

		$client->on(
			connect => sub {
				$client->write(to_json($init_message));
			}
		);
		
		$client->on(
			write => sub {
				my ($client, $buf) = @_;
				$ws_handle->push_write($buf);
			}
		);
		
		$client->on(
			read => sub {
				my ($self, $buf) = @_;
				$handler->('msg', $buf);
			}
		);

		$client->connect;
	};
	
	EV::run;
}

1;