#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;
use Getopt::Long;
use lib "./lib/";
use Engine::Fuzzer;
use Functions::Helper;

sub main {
    my ($target, $return);

    my $agent    = "Nozaki CLI / 0.6";
    my $delay    = 0;
    my $timeout  = 10;
    my $wordlist = "wordlists/default.txt";
    my $method   = "GET,POST,PUT,DELETE,HEAD,OPTIONS,CONNECT,TRACE,PATCH,SUBSCRIBE,MOVE,REPORT,UNLOCK,%s%s%s%s"
                    . "PURGE,POLL,NOTIFY,SEARCH,1337,CATS,*,DATA,HEADERS,PRIORITY,RST_STREAM,SETTINGS,PUSH_PROMISE"
                    . "PING,GOAWAY,WINDOW_UPDATE,CONTINUATION";

    GetOptions (
        "--url=s"      => \$target,
        "--wordlist=s" => \$wordlist,
        "--method=s"   => \$method,
        "--delay=i"    => \$delay,
        "--timeout=i"  => \$timeout,
        "--agent=s"    => \$agent,
        "--return=i"   => \$return
    ) or die ( return Functions::Helper -> new() );

    if ($target) {
        open (my $file, "<", $wordlist);

        while (<$file>) {
            chomp ($_);
            my $endpoint = $target.$_;

            my $fuzzer = Engine::Fuzzer -> new(
                $method,
                $endpoint,
                $timeout,
                $delay,
                $agent,
                $return
            );
        }

        close ($file);

        return 1;
    }

    return Functions::Helper -> new();
}

main();