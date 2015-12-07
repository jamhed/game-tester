package TestSpec::FrontPage;
use WS::Proto qw(on_msg on_bcast snmsg msg);
use WS::Spec qw(sid uid user run);
use Test::Spec;

describe "front page" => sub {
	it 'has one online user' => sub {
		my $text = shift->description;
		snmsg([sid, "user/online/count"], sub {
			my ($count) = @_;
			is($count, 1, $text);
		});
	};

	it 'has online user with same user id' => sub {
		my $text = shift->description;
		snmsg([sid, "user/online"], sub {
			my ($user) = @_;
			is($user->{id}, uid, $text);
		});
	};

	it 'handles user/logout correctly' => sub {
		my $text = shift->description;
		msg(["user/logout"], sub {
			ok(1, $text); # we were called in success only
		});
	};
};

run;
