Test WebSocket protocol
=======================

Requirements
------------

Linux, Perl, cpanm.

Setup
-----

$ cpanm EV AnyEvent AnyEvent::Socket AnyEvent::Handler Protocol::WebSocket::Client JSON Test::Spec

Test::Spec should be patched as in: https://github.com/kingpong/perl-Test-Spec/pull/30

Usage
-----

$ PERLLIB=./ ./proto.pl
