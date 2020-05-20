#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;
use Getopt::Long;
use lib "./lib/";
use Engine::Fuzzer;
use Functions::Helper;

# implement multi threads
# implement custom header
# implement fuzzing of mime type / http version / parameters
# implement output in json, supported by postman/insomnia/burp
# implement custom method http
# implement a feature to send a custom payload
# refact all wordlists
# define timeout / --timeout 3
# --return-length
# --exclude-length
# supported input files: swagger, openapi, graphql
# implement filter by http code / return and exclude

sub main {
    my (
        $target, $wordlist, $header, $threads, $param, $contentType, $method, $payload, $return, $exclude, $json,
        $delay
    );

    GetOptions (
        "--url=s"      => \$target, # ok
        "--wordlist=s" => \$wordlist, # ok
        "--header=s"   => \$header,
        "--threads=i"  => \$threads, # working here
        "--param"      => \$param,
        "--content-type"  => \$contentType, 
        "--method=s"   => \$method, # ok
        "--payload=s"  => \$payload,
        "--return=s"   => \$return,
        "--exclude=s"  => \$exclude,
        "--delay=i"    => \$delay, # ok
        "--json=s"     => \$json
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

        open (my $file, "<", $wordlist);

        while (<$file>) {
            chomp ($_);
            my $endpoint = $target.$_;

            my $fuzzer = Engine::Fuzzer -> new(
                $method,
                $endpoint,
                $delay
            );
        }

        close ($file);

        return 1;
    }

    return Functions::Helper -> new();
}

main();