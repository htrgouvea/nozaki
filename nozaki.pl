#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;
use Getopt::Long;
use lib "./lib/";
use Engine::Fuzzer;
use Functions::Helper;

sub main {
    my (
        $target, $wordlist, $method, $delay, $timeout, $proccess
    );

    GetOptions (
        "--url=s"      => \$target,
        "--wordlist=s" => \$wordlist,
        "--proccess=i" => \$proccess,
        "--method=s"   => \$method,
        "--delay=i"    => \$delay,
        "--timeout=i"  => \$timeout,
    ) or die (
        return Functions::Helper -> new()
    );

    if ($target) {
        if (!$wordlist) {
            $wordlist = "wordlists/default.txt";
        }

        if (!$delay) {
            $delay = 0;
        }

        if (!$method) {
            $method = "GET,POST,PUT,DELETE,HEAD,OPTIONS,CONNECT,TRACE,PATCH,SUBSCRIBE,MOVE,REPORT,UNLOCK,%s%s%s%s"
                    . "PURGE,POLL,NOTIFY,SEARCH,1337,CATS,*,DATA,HEADERS,PRIORITY,RST_STREAM,SETTINGS,PUSH_PROMISE"
                    . "PING,GOAWAY,WINDOW_UPDATE,CONTINUATION";
        }

        if (!$timeout) {
            $timeout = 10;
        }

        open (my $file, "<", $wordlist);

        while (<$file>) {
            chomp ($_);
            my $endpoint = $target.$_;

            my $fuzzer = Engine::Fuzzer -> new(
                $method,
                $endpoint,
                $timeout,
                $delay
            );
        }

        close ($file);

        return 1;
    }

    return Functions::Helper -> new();
}

main();

    # TO DO:
    # refact all wordlists
    # $payload  | implement a feature to send a custom payload
    # $json     | implement output in json, supported by postman/insomnia/burp
    # $header   | implement custom header
    # $proccess | implement multi threads
    # $param    | implement fuzzing of parameters
    # $mimeType | implement fuzzing of content type
    # $version  | implement fuzzing of http version
    # $return   | implement filter by http code / return 
    # $exclude  | implement filter by http code / exclude
    # $length   | filter for return-length / --exclude-length
    # supported input files: swagger, openapi, graphql